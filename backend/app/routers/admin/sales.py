"""Admin: overview stats, orders, customers and admin accounts."""

from __future__ import annotations

from datetime import timedelta

from fastapi import APIRouter
from sqlalchemy import func, or_, select
from sqlalchemy.orm import selectinload

from app.config import utcnow
from app.deps import AdminUser, DbSession
from app.errors import AppError
from app.models import (
    Favorite,
    Order,
    Product,
    Reminder,
    SupportTicket,
    User,
)
from app.routers.admin.common import get_or_404, iso, page_out, paginate
from app.routers.orders import serialize_order
from app.schemas import OrderStatusIn
from app.schemas.admin import AdminCreateIn, UserPatch
from app.security import hash_password
from app.services.auth_tokens import revoke_all_user_tokens
from app.services.notifications import notify_order_status
from app.services.phone import require_iraqi_phone
from app.services.ranking import popular_products, product_stats

router = APIRouter()


# ——— Overview ———


@router.get("/stats")
def stats(db: DbSession, _admin: AdminUser) -> dict:
    now = utcnow()
    today = now.replace(hour=0, minute=0, second=0, microsecond=0)
    valid = Order.status != "cancelled"

    def scalar(stmt) -> int:
        return int(db.scalar(stmt) or 0)

    by_status = dict(db.execute(select(Order.status, func.count(Order.id)).group_by(Order.status)).all())

    # Last 14 days series (orders & revenue per day).
    start = today - timedelta(days=13)
    day_col = func.date(Order.created_at)
    daily = {
        str(d): (int(c), int(r or 0))
        for d, c, r in db.execute(
            select(day_col, func.count(Order.id), func.sum(Order.total))
            .where(Order.created_at >= start, valid)
            .group_by(day_col)
        ).all()
    }
    series = []
    for i in range(14):
        day = (start + timedelta(days=i)).date().isoformat()
        count, revenue = daily.get(day, (0, 0))
        series.append({"date": day, "orders": count, "revenue": revenue})

    recent = db.scalars(
        select(Order).options(selectinload(Order.items)).order_by(Order.id.desc()).limit(8)
    ).all()
    top = popular_products(db, limit=5)
    top_stats = product_stats(db, [p.id for p in top])

    return {
        "orders_total": scalar(select(func.count(Order.id))),
        "orders_today": scalar(select(func.count(Order.id)).where(Order.created_at >= today)),
        "orders_pending": by_status.get("pending", 0),
        "orders_by_status": by_status,
        "revenue_total": scalar(select(func.sum(Order.total)).where(valid)),
        "revenue_today": scalar(
            select(func.sum(Order.total)).where(valid, Order.created_at >= today)
        ),
        "customers_total": scalar(select(func.count(User.id)).where(User.is_active.is_(True))),
        "customers_new_week": scalar(
            select(func.count(User.id)).where(User.created_at >= now - timedelta(days=7))
        ),
        "products_total": scalar(select(func.count(Product.id))),
        "products_active": scalar(
            select(func.count(Product.id)).where(Product.status == "active")
        ),
        "tickets_open": scalar(
            select(func.count(SupportTicket.id)).where(SupportTicket.status != "closed")
        ),
        "favorites_total": scalar(select(func.count(Favorite.id))),
        "reminders_total": scalar(select(func.count(Reminder.id))),
        "series": series,
        "recent_orders": [_order_row(o) for o in recent],
        "top_products": [
            {
                "id": p.id,
                "title_ar": p.title_ar,
                "cover_image": p.cover_image,
                "price": p.price,
                **top_stats.get(p.id, {"sold": 0, "favorites": 0, "score": 0}),
            }
            for p in top
        ],
    }


# ——— Orders ———


def _order_row(o: Order) -> dict:
    return {
        "id": o.id,
        "code": o.code,
        "status": o.status,
        "payment_method": o.payment_method,
        "recipient_name": o.recipient_name,
        "recipient_phone": o.recipient_phone,
        "governorate": o.governorate,
        "total": o.total,
        "items_count": sum(i.qty for i in o.items),
        "created_at": iso(o.created_at),
    }


@router.get("/orders")
def list_orders(
    db: DbSession,
    _admin: AdminUser,
    status: str | None = None,
    q: str | None = None,
    page: int = 1,
    page_size: int = 20,
) -> dict:
    stmt = select(Order).options(selectinload(Order.items)).order_by(Order.id.desc())
    if status:
        stmt = stmt.where(Order.status == status)
    if q:
        like = f"%{q.strip()}%"
        stmt = stmt.outerjoin(User, User.id == Order.user_id).where(
            or_(
                Order.code.ilike(like),
                Order.recipient_name.ilike(like),
                Order.recipient_phone.ilike(like),
                User.phone.ilike(like),
                User.name.ilike(like),
            )
        )
    rows, total = paginate(db, stmt, page, page_size)
    return page_out([_order_row(o) for o in rows], total, page, page_size)


def _order_detail(db: DbSession, order_id: int) -> dict:
    order = db.scalars(
        select(Order).where(Order.id == order_id).options(selectinload(Order.items))
    ).first()
    if order is None:
        raise AppError(404, "Order not found", code="NOT_FOUND")
    out = serialize_order(order).model_dump()
    out["items"] = [
        {
            "product_id": i.product_id,
            "title_ar": i.title_ar,
            "title_en": i.title_en,
            "image": i.image,
            "unit_price": i.unit_price,
            "qty": i.qty,
            "line_total": i.line_total,
        }
        for i in order.items
    ]
    customer = db.get(User, order.user_id)
    out["customer"] = (
        {"id": customer.id, "name": customer.name, "phone": customer.phone}
        if customer
        else None
    )
    return out


@router.get("/orders/{order_id}")
def get_order(order_id: int, db: DbSession, _admin: AdminUser) -> dict:
    return _order_detail(db, order_id)


@router.patch("/orders/{order_id}/status")
def set_order_status(
    order_id: int, payload: OrderStatusIn, db: DbSession, _admin: AdminUser
) -> dict:
    order = get_or_404(db, Order, order_id, "Order")
    if order.status != payload.status:
        order.status = payload.status
        notify_order_status(db, order)  # the customer gets an in-app notification
        db.commit()
    return _order_detail(db, order_id)


# ——— Customers ———


def _user_row(u: User, orders: int = 0, spent: int = 0) -> dict:
    return {
        "id": u.id,
        "name": u.name,
        "phone": u.phone,
        "email": u.email,
        "governorate": u.governorate,
        "is_active": u.is_active,
        "is_admin": u.is_admin,
        "notifications_enabled": u.notifications_enabled,
        "locale": u.locale,
        "orders_count": orders,
        "total_spent": spent,
        "created_at": iso(u.created_at),
    }


@router.get("/users")
def list_users(
    db: DbSession,
    _admin: AdminUser,
    q: str | None = None,
    role: str | None = None,
    page: int = 1,
    page_size: int = 20,
) -> dict:
    stmt = select(User).order_by(User.id.desc())
    if q:
        like = f"%{q.strip()}%"
        stmt = stmt.where(or_(User.name.ilike(like), User.phone.ilike(like)))
    if role == "admin":
        stmt = stmt.where(User.is_admin.is_(True))
    elif role == "customer":
        stmt = stmt.where(User.is_admin.is_(False))
    elif role == "inactive":
        stmt = stmt.where(User.is_active.is_(False))
    rows, total = paginate(db, stmt, page, page_size)
    ids = [u.id for u in rows]
    agg = {
        uid: (int(c), int(s or 0))
        for uid, c, s in db.execute(
            select(Order.user_id, func.count(Order.id), func.sum(Order.total))
            .where(Order.user_id.in_(ids), Order.status != "cancelled")
            .group_by(Order.user_id)
        ).all()
    } if ids else {}
    return page_out(
        [_user_row(u, *agg.get(u.id, (0, 0))) for u in rows], total, page, page_size
    )


@router.get("/users/{user_id}")
def get_user(user_id: int, db: DbSession, _admin: AdminUser) -> dict:
    user = get_or_404(db, User, user_id, "User")
    orders = db.scalars(
        select(Order)
        .where(Order.user_id == user.id)
        .options(selectinload(Order.items))
        .order_by(Order.id.desc())
        .limit(50)
    ).all()
    valid = [o for o in orders if o.status != "cancelled"]
    out = _user_row(user, len(valid), sum(o.total for o in valid))
    out["orders"] = [_order_row(o) for o in orders]
    out["favorites_count"] = int(
        db.scalar(select(func.count(Favorite.id)).where(Favorite.user_id == user.id)) or 0
    )
    out["reminders_count"] = int(
        db.scalar(select(func.count(Reminder.id)).where(Reminder.user_id == user.id)) or 0
    )
    return out


@router.patch("/users/{user_id}")
def update_user(user_id: int, payload: UserPatch, db: DbSession, admin: AdminUser) -> dict:
    user = get_or_404(db, User, user_id, "User")
    if user.id == admin.id and (payload.is_admin is False or payload.is_active is False):
        raise AppError(400, "You cannot remove your own admin access", code="SELF_LOCKOUT")
    data = payload.model_dump(exclude_unset=True)
    for key, value in data.items():
        if value is not None:
            setattr(user, key, value)
    if payload.is_active is False:
        revoke_all_user_tokens(db, user.id)
    db.commit()
    return get_user(user.id, db, admin)


@router.post("/admins")
def create_admin(payload: AdminCreateIn, db: DbSession, admin: AdminUser) -> dict:
    phone = require_iraqi_phone(payload.phone)
    user = db.scalars(select(User).where(User.phone == phone)).first()
    if user is None:
        user = User(phone=phone, name=payload.name.strip())
        db.add(user)
    user.password_hash = hash_password(payload.password)
    user.name = payload.name.strip()
    user.is_admin = True
    user.is_active = True
    db.commit()
    return get_user(user.id, db, admin)

