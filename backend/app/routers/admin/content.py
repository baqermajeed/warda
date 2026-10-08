"""Admin: notifications, FAQ, privacy policy, support tickets and app settings."""

from __future__ import annotations

import uuid

from fastapi import APIRouter
from sqlalchemy import delete, func, select
from sqlalchemy.orm import selectinload

from app.deps import AdminUser, DbSession
from app.errors import AppError
from app.models import (
    AppSetting,
    FaqCategory,
    FaqItem,
    Notification,
    PrivacySection,
    SupportTicket,
    User,
)
from app.routers.admin.common import (
    apply_patch,
    bust_public_cache,
    ensure_unique,
    fill_english,
    get_or_404,
    iso,
    page_out,
    paginate,
)
from app.schemas import OkOut
from app.schemas.admin import (
    BroadcastIn,
    FaqCategoryIn,
    FaqCategoryPatch,
    FaqItemIn,
    FaqItemPatch,
    PrivacyIn,
    PrivacyPatch,
    SettingsIn,
    TicketPatch,
)
from app.services.app_settings import INT_SETTINGS, SETTING_DEFAULTS, all_settings
from app.services.notifications import notify
from app.services.phone import require_iraqi_phone

router = APIRouter()

BROADCAST_PREFIX = "admin:"


# ——— Notifications ———


@router.post("/notifications")
def send_notification(payload: BroadcastIn, db: DbSession, _admin: AdminUser) -> dict:
    key = f"{BROADCAST_PREFIX}{uuid.uuid4().hex}"
    if payload.phone and payload.phone.strip():
        phone = require_iraqi_phone(payload.phone)
        target = db.scalars(select(User).where(User.phone == phone)).first()
        if target is None:
            raise AppError(404, "No user with this phone", code="USER_NOT_FOUND")
        user_ids = [target.id]
    else:
        user_ids = list(
            db.scalars(
                select(User.id).where(
                    User.is_active.is_(True), User.notifications_enabled.is_(True)
                )
            ).all()
        )
    link = (payload.link or "").strip() or None
    for uid in user_ids:
        notify(
            db,
            uid,
            type="admin",
            title_ar=payload.title_ar.strip(),
            title_en=(payload.title_en or payload.title_ar).strip(),
            body_ar=payload.body_ar.strip(),
            body_en=(payload.body_en or payload.body_ar).strip(),
            link=link,
            dedupe_key=key,
        )
    db.commit()
    return {"key": key, "recipients": len(user_ids)}


@router.get("/notifications")
def notification_history(
    db: DbSession, _admin: AdminUser, page: int = 1, page_size: int = 20
) -> dict:
    """One row per sent message (a broadcast is stored once per recipient)."""
    base = (
        select(
            Notification.dedupe_key,
            func.min(Notification.title_ar),
            func.min(Notification.body_ar),
            func.min(Notification.link),
            func.min(Notification.created_at),
            func.count(Notification.id),
            func.count(Notification.read_at),
        )
        .where(Notification.type == "admin", Notification.dedupe_key.like(f"{BROADCAST_PREFIX}%"))
        .group_by(Notification.dedupe_key)
    )
    total = db.scalar(select(func.count()).select_from(base.subquery())) or 0
    page, page_size = max(1, page), min(max(1, page_size), 100)
    rows = db.execute(
        base.order_by(func.min(Notification.created_at).desc())
        .offset((page - 1) * page_size)
        .limit(page_size)
    ).all()
    items = [
        {
            "key": key,
            "title_ar": title,
            "body_ar": body,
            "link": link,
            "created_at": iso(created),
            "recipients": int(count),
            "read": int(read),
        }
        for key, title, body, link, created, count, read in rows
    ]
    return page_out(items, total, page, page_size)


@router.delete("/notifications/{key}", response_model=OkOut)
def delete_notification(key: str, db: DbSession, _admin: AdminUser) -> OkOut:
    if not key.startswith(BROADCAST_PREFIX):
        raise AppError(400, "Invalid key", code="INVALID_KEY")
    db.execute(delete(Notification).where(Notification.dedupe_key == key))
    db.commit()
    return OkOut()


# ——— FAQ ———


def _faq_item_out(i: FaqItem) -> dict:
    return {
        "id": i.id,
        "category_id": i.category_id,
        "question_ar": i.question_ar,
        "question_en": i.question_en,
        "answer_ar": i.answer_ar,
        "answer_en": i.answer_en,
        "sort_order": i.sort_order,
    }


def _faq_category_out(c: FaqCategory) -> dict:
    return {
        "id": c.id,
        "slug": c.slug,
        "title_ar": c.title_ar,
        "title_en": c.title_en,
        "sort_order": c.sort_order,
        "items": [
            _faq_item_out(i) for i in sorted(c.items, key=lambda x: (x.sort_order, x.id))
        ],
    }


@router.get("/faq")
def list_faq(db: DbSession, _admin: AdminUser) -> list[dict]:
    rows = db.scalars(
        select(FaqCategory)
        .options(selectinload(FaqCategory.items))
        .order_by(FaqCategory.sort_order, FaqCategory.id)
    ).all()
    return [_faq_category_out(c) for c in rows]


@router.post("/faq/categories")
def create_faq_category(payload: FaqCategoryIn, db: DbSession, _admin: AdminUser) -> dict:
    ensure_unique(db, FaqCategory, "slug", payload.slug)
    row = FaqCategory(**payload.model_dump())
    fill_english(row, "title")
    db.add(row)
    db.commit()
    db.refresh(row)
    return _faq_category_out(row)


@router.patch("/faq/categories/{category_id}")
def update_faq_category(
    category_id: int, payload: FaqCategoryPatch, db: DbSession, _admin: AdminUser
) -> dict:
    row = get_or_404(db, FaqCategory, category_id, "FAQ category")
    if payload.slug:
        ensure_unique(db, FaqCategory, "slug", payload.slug, exclude_id=row.id)
    apply_patch(row, payload, required={"slug", "title_ar", "title_en", "sort_order"})
    fill_english(row, "title")
    db.commit()
    db.refresh(row)
    return _faq_category_out(row)


@router.delete("/faq/categories/{category_id}", response_model=OkOut)
def delete_faq_category(category_id: int, db: DbSession, _admin: AdminUser) -> OkOut:
    row = get_or_404(db, FaqCategory, category_id, "FAQ category")
    db.execute(delete(FaqItem).where(FaqItem.category_id == row.id))
    db.delete(row)
    db.commit()
    return OkOut()


@router.post("/faq/items")
def create_faq_item(payload: FaqItemIn, db: DbSession, _admin: AdminUser) -> dict:
    get_or_404(db, FaqCategory, payload.category_id, "FAQ category")
    row = FaqItem(**payload.model_dump())
    fill_english(row, "question", "answer")
    db.add(row)
    db.commit()
    return _faq_item_out(row)


@router.patch("/faq/items/{item_id}")
def update_faq_item(
    item_id: int, payload: FaqItemPatch, db: DbSession, _admin: AdminUser
) -> dict:
    row = get_or_404(db, FaqItem, item_id, "FAQ item")
    if payload.category_id is not None:
        get_or_404(db, FaqCategory, payload.category_id, "FAQ category")
    apply_patch(
        row,
        payload,
        required={"category_id", "question_ar", "question_en", "answer_ar", "answer_en", "sort_order"},
    )
    fill_english(row, "question", "answer")
    db.commit()
    return _faq_item_out(row)


@router.delete("/faq/items/{item_id}", response_model=OkOut)
def delete_faq_item(item_id: int, db: DbSession, _admin: AdminUser) -> OkOut:
    db.delete(get_or_404(db, FaqItem, item_id, "FAQ item"))
    db.commit()
    return OkOut()


# ——— Privacy policy ———


def _privacy_out(r: PrivacySection) -> dict:
    return {
        "id": r.id,
        "slug": r.slug,
        "title_ar": r.title_ar,
        "title_en": r.title_en,
        "body_ar": r.body_ar,
        "body_en": r.body_en,
        "sort_order": r.sort_order,
        "updated_at": iso(r.updated_at),
    }


@router.get("/privacy")
def list_privacy(db: DbSession, _admin: AdminUser) -> list[dict]:
    rows = db.scalars(
        select(PrivacySection).order_by(PrivacySection.sort_order, PrivacySection.id)
    ).all()
    return [_privacy_out(r) for r in rows]


@router.post("/privacy")
def create_privacy(payload: PrivacyIn, db: DbSession, _admin: AdminUser) -> dict:
    ensure_unique(db, PrivacySection, "slug", payload.slug)
    row = PrivacySection(**payload.model_dump())
    fill_english(row, "title", "body")
    db.add(row)
    db.commit()
    return _privacy_out(row)


@router.patch("/privacy/{section_id}")
def update_privacy(
    section_id: int, payload: PrivacyPatch, db: DbSession, _admin: AdminUser
) -> dict:
    row = get_or_404(db, PrivacySection, section_id, "Privacy section")
    if payload.slug:
        ensure_unique(db, PrivacySection, "slug", payload.slug, exclude_id=row.id)
    apply_patch(
        row, payload, required={"slug", "title_ar", "title_en", "body_ar", "body_en", "sort_order"}
    )
    fill_english(row, "title", "body")
    db.commit()
    return _privacy_out(row)


@router.delete("/privacy/{section_id}", response_model=OkOut)
def delete_privacy(section_id: int, db: DbSession, _admin: AdminUser) -> OkOut:
    db.delete(get_or_404(db, PrivacySection, section_id, "Privacy section"))
    db.commit()
    return OkOut()


# ——— Support tickets ———


def _ticket_out(t: SupportTicket, user: User | None = None) -> dict:
    return {
        "id": t.id,
        "user_id": t.user_id,
        "user_name": user.name if user else None,
        "name": t.name,
        "phone": t.phone,
        "subject": t.subject,
        "message": t.message,
        "status": t.status,
        "created_at": iso(t.created_at),
        "updated_at": iso(t.updated_at),
    }


@router.get("/support/tickets")
def list_tickets(
    db: DbSession,
    _admin: AdminUser,
    status: str | None = None,
    page: int = 1,
    page_size: int = 20,
) -> dict:
    stmt = select(SupportTicket).order_by(SupportTicket.id.desc())
    if status:
        stmt = stmt.where(SupportTicket.status == status)
    rows, total = paginate(db, stmt, page, page_size)
    users = {
        u.id: u
        for u in db.scalars(
            select(User).where(User.id.in_([t.user_id for t in rows if t.user_id]))
        ).all()
    }
    return page_out(
        [_ticket_out(t, users.get(t.user_id)) for t in rows], total, page, page_size
    )


@router.patch("/support/tickets/{ticket_id}")
def update_ticket(
    ticket_id: int, payload: TicketPatch, db: DbSession, _admin: AdminUser
) -> dict:
    ticket = get_or_404(db, SupportTicket, ticket_id, "Ticket")
    reply = (payload.reply or "").strip()
    if reply:
        if ticket.user_id is None:
            raise AppError(
                400,
                "This ticket was sent without an account; contact the customer by phone",
                code="NO_ACCOUNT",
            )
        notify(
            db,
            ticket.user_id,
            type="support",
            title_ar=f"رد خدمة العملاء: {ticket.subject}",
            title_en=f"Support reply: {ticket.subject}",
            body_ar=reply,
            body_en=reply,
            link="/support",
        )
        if payload.status is None and ticket.status == "open":
            ticket.status = "in_progress"
    if payload.status:
        ticket.status = payload.status
    db.commit()
    user = db.get(User, ticket.user_id) if ticket.user_id else None
    return _ticket_out(ticket, user)


@router.delete("/support/tickets/{ticket_id}", response_model=OkOut)
def delete_ticket(ticket_id: int, db: DbSession, _admin: AdminUser) -> OkOut:
    db.delete(get_or_404(db, SupportTicket, ticket_id, "Ticket"))
    db.commit()
    return OkOut()


# ——— Settings ———


@router.get("/settings")
def get_settings(db: DbSession, _admin: AdminUser) -> dict:
    return all_settings(db)


@router.put("/settings")
def put_settings(payload: SettingsIn, db: DbSession, _admin: AdminUser) -> dict:
    unknown = set(payload.values) - set(SETTING_DEFAULTS)
    if unknown:
        raise AppError(400, f"Unknown settings: {', '.join(sorted(unknown))}", code="UNKNOWN_SETTING")
    for key, raw in payload.values.items():
        value = raw.strip()
        if key in INT_SETTINGS:
            if not value.isdigit():
                raise AppError(400, f"{key} must be a whole number", code="INVALID_SETTING")
        row = db.get(AppSetting, key)
        if row is None:
            db.add(AppSetting(key=key, value=value))
        else:
            row.value = value
    db.commit()
    bust_public_cache()
    return all_settings(db)
