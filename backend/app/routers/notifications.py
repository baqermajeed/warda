from __future__ import annotations

from fastapi import APIRouter
from sqlalchemy import func, select, update

from app.config import utcnow
from app.deps import CurrentUser, DbSession
from app.errors import AppError
from app.models import Notification
from app.schemas import OkOut, Page
from app.services.notifications import notification_out, sync_reminder_notifications

router = APIRouter(prefix="/notifications", tags=["notifications"])


@router.get("", response_model=Page)
def list_notifications(
    db: DbSession,
    user: CurrentUser,
    page: int = 1,
    page_size: int = 20,
) -> Page:
    sync_reminder_notifications(db, user)
    page = max(1, page)
    page_size = min(max(1, page_size), 100)
    base = select(Notification).where(Notification.user_id == user.id)
    total = db.scalar(select(func.count()).select_from(base.subquery())) or 0
    rows = db.scalars(
        base.order_by(Notification.created_at.desc(), Notification.id.desc())
        .offset((page - 1) * page_size)
        .limit(page_size)
    ).all()
    return Page(
        items=[notification_out(r).model_dump() for r in rows],
        total=total,
        page=page,
        page_size=page_size,
    )


@router.get("/unread-count")
def unread_count(db: DbSession, user: CurrentUser) -> dict:
    sync_reminder_notifications(db, user)
    count = db.scalar(
        select(func.count())
        .select_from(Notification)
        .where(Notification.user_id == user.id, Notification.read_at.is_(None))
    )
    return {"count": count or 0}


@router.post("/read-all", response_model=OkOut)
def read_all(db: DbSession, user: CurrentUser) -> OkOut:
    db.execute(
        update(Notification)
        .where(Notification.user_id == user.id, Notification.read_at.is_(None))
        .values(read_at=utcnow())
    )
    db.commit()
    return OkOut()


@router.post("/{notification_id}/read", response_model=OkOut)
def read_one(notification_id: int, db: DbSession, user: CurrentUser) -> OkOut:
    row = db.get(Notification, notification_id)
    if row is None or row.user_id != user.id:
        raise AppError(404, "Notification not found", code="NOTIFICATION_NOT_FOUND")
    if row.read_at is None:
        row.read_at = utcnow()
        db.commit()
    return OkOut()


@router.delete("/{notification_id}", response_model=OkOut)
def delete_one(notification_id: int, db: DbSession, user: CurrentUser) -> OkOut:
    row = db.get(Notification, notification_id)
    if row is None or row.user_id != user.id:
        raise AppError(404, "Notification not found", code="NOTIFICATION_NOT_FOUND")
    db.delete(row)
    db.commit()
    return OkOut()
