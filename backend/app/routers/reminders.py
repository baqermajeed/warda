from __future__ import annotations

from datetime import datetime

from fastapi import APIRouter

from app.config import utcnow
from app.deps import CurrentUser
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
async def list_reminders(user: CurrentUser) -> list[ReminderOut]:
    rows = await Reminder.find(Reminder.user_id == user.id).sort("+date").to_list()
    return [_out(r) for r in rows]


@router.post("", response_model=ReminderOut)
async def create_reminder(payload: ReminderIn, user: CurrentUser) -> ReminderOut:
    row = Reminder(
        user_id=user.id,
        person_name=payload.person_name.strip(),
        type_id=payload.type_id,
        date=_parse_date(payload.date),
        notify_enabled=payload.notify_enabled,
        remind_days_before=payload.remind_days_before,
        note=payload.note,
    )
    await row.insert()
    return _out(row)


@router.put("/{reminder_id}", response_model=ReminderOut)
async def update_reminder(
    reminder_id: int, payload: ReminderIn, user: CurrentUser
) -> ReminderOut:
    row = await Reminder.find_one(Reminder.id == reminder_id, Reminder.user_id == user.id)
    if row is None:
        raise AppError(404, "Reminder not found", code="REMINDER_NOT_FOUND")
    row.person_name = payload.person_name.strip()
    row.type_id = payload.type_id
    row.date = _parse_date(payload.date)
    row.notify_enabled = payload.notify_enabled
    row.remind_days_before = payload.remind_days_before
    row.note = payload.note
    row.updated_at = utcnow()
    await row.save()
    return _out(row)


@router.delete("/{reminder_id}", response_model=OkOut)
async def delete_reminder(reminder_id: int, user: CurrentUser) -> OkOut:
    row = await Reminder.find_one(Reminder.id == reminder_id, Reminder.user_id == user.id)
    if row:
        await row.delete()
    return OkOut()
