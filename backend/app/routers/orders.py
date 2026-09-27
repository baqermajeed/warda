from __future__ import annotations

import json
import secrets
from datetime import datetime

from fastapi import APIRouter
from sqlalchemy import select
from sqlalchemy.orm import selectinload

from app.deps import CurrentUser, DbSession
from app.errors import AppError
from app.models import CartItem, Order, OrderItem, Product
from app.schemas import OkOut, OrderCreateIn, OrderOut, Page
from app.services.phone import require_iraqi_phone
from app.services.pricing import calc_pricing, get_or_create_cart, set_addon_ids
from app.services.auth_tokens import parse_json_list, parse_json_obj

router = APIRouter(prefix="/orders", tags=["orders"])


def _order_code() -> str:
    return f"W{secrets.token_hex(4).upper()}"


def serialize_order(order: Order) -> OrderOut:
    return OrderOut(
        id=order.id,
        code=order.code,
        status=order.status,
        payment_method=order.payment_method,
        recipient_name=order.recipient_name,
        recipient_phone=order.recipient_phone,
        governorate=order.governorate,
        landmark=order.landmark,
        unknown_address=order.unknown_address,
        items=[
            {
                "title_ar": i.title_ar,
                "title_en": i.title_en,
                "image": i.image,
                "unit_price": i.unit_price,
                "qty": i.qty,
                "line_total": i.line_total,
            }
            for i in order.items
        ],
        gift_card=parse_json_obj(order.gift_card_snapshot) or None,
        wrap=parse_json_obj(order.wrap_snapshot) or None,
        addons=parse_json_list(order.addons_snapshot),
        gift_from=order.gift_from,
        gift_to=order.gift_to,
        gift_message=order.gift_message,
        subtotal=order.subtotal,
        wrap_price=order.wrap_price,
        addons_price=order.addons_price,
        card_price=order.card_price,
        delivery_price=order.delivery_price,
        total=order.total,
        created_at=order.created_at.isoformat() if order.created_at else "",
    )


@router.post("", response_model=OrderOut)
def create_order(payload: OrderCreateIn, db: DbSession, user: CurrentUser) -> OrderOut:
    cart = get_or_create_cart(db, user.id)
    if not cart.items:
        raise AppError(400, "Cart is empty", code="CART_EMPTY")

    phone = require_iraqi_phone(payload.recipient_phone)
    if not payload.unknown_address and not payload.governorate:
        raise AppError(400, "Governorate required", code="GOVERNORATE_REQUIRED")

    pricing = calc_pricing(db, cart)
    order = Order(
        code=_order_code(),
        user_id=user.id,
        status="pending",
        payment_method=payload.payment_method,
        recipient_name=payload.recipient_name.strip(),
        recipient_phone=phone,
        governorate=None if payload.unknown_address else payload.governorate,
        landmark="" if payload.unknown_address else payload.landmark,
        unknown_address=payload.unknown_address,
        subtotal=pricing["subtotal"],
        wrap_price=pricing["wrap_price"],
        addons_price=pricing["addons_price"],
        card_price=pricing["card_price"],
        delivery_price=pricing["delivery_price"],
        total=pricing["total"],
        gift_from=cart.gift_from,
        gift_to=cart.gift_to,
        gift_message=cart.gift_message,
        gift_card_snapshot=json.dumps(
            {
                "id": cart.gift_card.id,
                "title_ar": cart.gift_card.title_ar,
                "title_en": cart.gift_card.title_en,
                "price": cart.gift_card.price,
                "image": cart.gift_card.image,
            }
            if cart.gift_card
            else {},
            ensure_ascii=False,
        ),
        wrap_snapshot=json.dumps(
            {
                "id": cart.wrap.id,
                "title_ar": cart.wrap.title_ar,
                "title_en": cart.wrap.title_en,
                "price": cart.wrap.price,
                "image": cart.wrap.image,
            }
            if cart.wrap
            else {},
            ensure_ascii=False,
        ),
        addons_snapshot=json.dumps(
            [
                {
                    "id": a.id,
                    "title_ar": a.title_ar,
                    "title_en": a.title_en,
                    "price": a.price,
                    "image": a.image,
                }
                for a in pricing["addons"]
            ],
            ensure_ascii=False,
        ),
    )
    db.add(order)
    db.flush()

    for item in cart.items:
        p = item.product
        db.add(
            OrderItem(
                order_id=order.id,
                product_id=item.product_id,
                title_ar=p.title_ar if p else "Product",
                title_en=p.title_en if p else "Product",
                image=p.cover_image if p else None,
                unit_price=item.unit_price,
                qty=item.qty,
                line_total=item.unit_price * item.qty,
            )
        )

    # Clear cart after successful snapshot
    for item in list(cart.items):
        db.delete(item)
    cart.gift_card_id = None
    cart.wrap_id = None
    cart.gift_from = ""
    cart.gift_to = ""
    cart.gift_message = ""
    set_addon_ids(cart, [])
    db.commit()

    order = db.scalars(
        select(Order).where(Order.id == order.id).options(selectinload(Order.items))
    ).one()
    return serialize_order(order)


@router.get("", response_model=Page)
def list_orders(
    db: DbSession,
    user: CurrentUser,
    page: int = 1,
    page_size: int = 20,
) -> Page:
    page = max(1, page)
    page_size = min(max(1, page_size), 100)
    stmt = (
        select(Order)
        .where(Order.user_id == user.id)
        .options(selectinload(Order.items))
        .order_by(Order.id.desc())
    )
    rows = db.scalars(stmt).all()
    total = len(rows)
    chunk = rows[(page - 1) * page_size : (page - 1) * page_size + page_size]
    return Page(
        items=[serialize_order(o).model_dump() for o in chunk],
        total=total,
        page=page,
        page_size=page_size,
    )


@router.get("/{order_id}", response_model=OrderOut)
def get_order(order_id: int, db: DbSession, user: CurrentUser) -> OrderOut:
    order = db.scalars(
        select(Order)
        .where(Order.id == order_id, Order.user_id == user.id)
        .options(selectinload(Order.items))
    ).first()
    if order is None:
        raise AppError(404, "Order not found", code="ORDER_NOT_FOUND")
    return serialize_order(order)


@router.post("/{order_id}/reorder", response_model=OkOut)
def reorder(order_id: int, db: DbSession, user: CurrentUser) -> OkOut:
    order = db.scalars(
        select(Order)
        .where(Order.id == order_id, Order.user_id == user.id)
        .options(selectinload(Order.items))
    ).first()
    if order is None:
        raise AppError(404, "Order not found", code="ORDER_NOT_FOUND")
    cart = get_or_create_cart(db, user.id)
    for item in order.items:
        if item.product_id is None:
            continue
        product = db.get(Product, item.product_id)
        if product is None or product.status != "active":
            continue
        existing = next((i for i in cart.items if i.product_id == product.id), None)
        if existing:
            existing.qty += item.qty
            existing.unit_price = product.price
        else:
            db.add(
                CartItem(
                    cart_id=cart.id,
                    product_id=product.id,
                    qty=item.qty,
                    unit_price=product.price,
                )
            )
    db.commit()
    return OkOut()
