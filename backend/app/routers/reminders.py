from __future__ import annotations

from datetime import datetime

from fastapi import APIRouter
from sqlalchemy import select

from app.deps import CurrentUser, DbSession
from app.errors import AppError
from app.models import Reminder
from app.schemas import OkOut, ReminderIn, ReminderOut

router = APIRouter(prefix="/reminders", tags=["reminders"])


def _parse_date(value: str) -> datetime:
    try:
        if "T" in value:
            return datetime.fromisoformat(value.replace("Z", ""))
        return datetime.fromisoformat(f"{value}T00:00:00")
    except Exception as exc:
        raise AppError(400, "Invalid date", code="INVALID_DATE") from exc


def _out(row: Reminder) -> ReminderOut:
    return ReminderOut(
        id=row.id,
        person_name=row.person_name,
        type_id=row.type_id,
        date=row.date.date().isoformat(),
        notify_enabled=row.notify_enabled,
        remind_days_before=row.remind_days_before,
        note=row.note,
    )


@router.get("", response_model=list[ReminderOut])
def list_reminders(db: DbSession, user: CurrentUser) -> list[ReminderOut]:
    rows = db.scalars(
        select(Reminder).where(Reminder.user_id == user.id).order_by(Reminder.date.asc())
    ).all()
    return [_out(r) for r in rows]


@router.post("", response_model=ReminderOut)
def create_reminder(payload: ReminderIn, db: DbSession, user: CurrentUser) -> ReminderOut:
    row = Reminder(
        user_id=user.id,
        person_name=payload.person_name.strip(),
        type_id=payload.type_id,
        date=_parse_date(payload.date),
        notify_enabled=payload.notify_enabled,
        remind_days_before=payload.remind_days_before,
        note=payload.note,
    )
    db.add(row)
    db.commit()
    db.refresh(row)
    return _out(row)


@router.put("/{reminder_id}", response_model=ReminderOut)
def update_reminder(
    reminder_id: int, payload: ReminderIn, db: DbSession, user: CurrentUser
) -> ReminderOut:
    row = db.scalars(
        select(Reminder).where(Reminder.id == reminder_id, Reminder.user_id == user.id)
    ).first()
    if row is None:
        raise AppError(404, "Reminder not found", code="REMINDER_NOT_FOUND")
    row.person_name = payload.person_name.strip()
    row.type_id = payload.type_id
    row.date = _parse_date(payload.date)
    row.notify_enabled = payload.notify_enabled
    row.remind_days_before = payload.remind_days_before
    row.note = payload.note
    db.commit()
    db.refresh(row)
    return _out(row)


@router.delete("/{reminder_id}", response_model=OkOut)
def delete_reminder(reminder_id: int, db: DbSession, user: CurrentUser) -> OkOut:
    row = db.scalars(
        select(Reminder).where(Reminder.id == reminder_id, Reminder.user_id == user.id)
    ).first()
    if row:
        db.delete(row)
        db.commit()
    return OkOut()
