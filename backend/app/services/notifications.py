from __future__ import annotations

from datetime import date, datetime

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.config import utcnow
from app.models import Notification, Order, Reminder, User
from app.schemas import NotificationOut

ORDER_STATUS_TEXT = {
    "pending": ("تم استلام طلبك", "Order received"),
    "confirmed": ("تم تأكيد طلبك", "Order confirmed"),
    "shipping": ("طلبك في الطريق", "Your order is on the way"),
    "delivered": ("تم توصيل طلبك", "Order delivered"),
    "cancelled": ("تم إلغاء طلبك", "Order cancelled"),
}


def notify(
    db: Session,
    user_id: int,
    *,
    type: str,
    title_ar: str,
    title_en: str,
    body_ar: str = "",
    body_en: str = "",
    link: str | None = None,
    dedupe_key: str | None = None,
) -> Notification | None:
    """Adds a notification (caller commits). Skips duplicates by `dedupe_key`."""
    if dedupe_key is not None:
        exists = db.scalars(
            select(Notification.id).where(
                Notification.user_id == user_id, Notification.dedupe_key == dedupe_key
            )
        ).first()
        if exists is not None:
            return None
    row = Notification(
        user_id=user_id,
        type=type,
        title_ar=title_ar,
        title_en=title_en,
        body_ar=body_ar,
        body_en=body_en,
        link=link,
        dedupe_key=dedupe_key,
    )
    db.add(row)
    return row


def notify_order_status(db: Session, order: Order) -> None:
    title_ar, title_en = ORDER_STATUS_TEXT.get(order.status, ORDER_STATUS_TEXT["pending"])
    notify(
        db,
        order.user_id,
        type="order",
        title_ar=title_ar,
        title_en=title_en,
        body_ar=f"رقم الطلب {order.code}",
        body_en=f"Order {order.code}",
        link=f"/orders/{order.id}",
        dedupe_key=f"order:{order.id}:{order.status}",
    )


def _next_occurrence(day: date, today: date) -> date:
    if day >= today:
        return day
    for year in (today.year, today.year + 1):
        try:
            candidate = day.replace(year=year)
        except ValueError:  # 29 Feb in a non-leap year
            candidate = date(year, 3, 1)
        if candidate >= today:
            return candidate
    return day


def sync_reminder_notifications(db: Session, user: User) -> None:
    """Creates a notification for every reminder whose date is within its notice window."""
    if not user.notifications_enabled:
        return
    today = utcnow().date()
    rows = db.scalars(
        select(Reminder).where(Reminder.user_id == user.id, Reminder.notify_enabled.is_(True))
    ).all()
    for r in rows:
        occurs = _next_occurrence(r.date.date(), today)
        days_left = (occurs - today).days
        if days_left > r.remind_days_before:
            continue
        if days_left == 0:
            body_ar, body_en = "اليوم", "Today"
        else:
            body_ar, body_en = f"بعد {days_left} يوم", f"In {days_left} day(s)"
        notify(
            db,
            user.id,
            type="reminder",
            title_ar=f"مناسبة {r.person_name} تقترب",
            title_en=f"{r.person_name}'s occasion is coming up",
            body_ar=body_ar,
            body_en=body_en,
            link="/reminders",
            dedupe_key=f"reminder:{r.id}:{occurs.isoformat()}",
        )
    db.commit()


def notification_out(row: Notification) -> NotificationOut:
    created: datetime = row.created_at
    return NotificationOut(
        id=row.id,
        type=row.type,
        title_ar=row.title_ar,
        title_en=row.title_en,
        body_ar=row.body_ar,
        body_en=row.body_en,
        link=row.link,
        is_read=row.read_at is not None,
        created_at=created.isoformat() if created else "",
    )
