from __future__ import annotations

import json
import secrets

from fastapi import APIRouter

from app.db import next_seq
from app.deps import CurrentUser
from app.errors import AppError
from app.models import CartItemEmbed, Order, OrderItemEmbed, Product
from app.schemas import OkOut, OrderCreateIn, OrderOut, Page
from app.services.phone import require_iraqi_phone
from app.services.pricing import calc_pricing, get_or_create_cart, set_addon_ids, touch_cart
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
async def create_order(payload: OrderCreateIn, user: CurrentUser) -> OrderOut:
    cart = await get_or_create_cart(user.id)
    if not cart.items:
        raise AppError(400, "Cart is empty", code="CART_EMPTY")

    phone = require_iraqi_phone(payload.recipient_phone)
    if not payload.unknown_address and not payload.governorate:
        raise AppError(400, "Governorate required", code="GOVERNORATE_REQUIRED")

    pricing = await calc_pricing(cart)
    gift_card = pricing.get("gift_card")
    wrap = pricing.get("wrap")

    order_items: list[OrderItemEmbed] = []
    for item in cart.items:
        p = await Product.find_one(Product.id == item.product_id)
        order_items.append(
            OrderItemEmbed(
                id=await next_seq("order_items"),
                product_id=item.product_id,
                title_ar=p.title_ar if p else "Product",
                title_en=p.title_en if p else "Product",
                image=p.cover_image if p else None,
                unit_price=item.unit_price,
                qty=item.qty,
                line_total=item.unit_price * item.qty,
            )
        )

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
                "id": gift_card.id,
                "title_ar": gift_card.title_ar,
                "title_en": gift_card.title_en,
                "price": gift_card.price,
                "image": gift_card.image,
            }
            if gift_card
            else {},
            ensure_ascii=False,
        ),
        wrap_snapshot=json.dumps(
            {
                "id": wrap.id,
                "title_ar": wrap.title_ar,
                "title_en": wrap.title_en,
                "price": wrap.price,
                "image": wrap.image,
            }
            if wrap
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
        items=order_items,
    )
    await order.insert()

    cart.items = []
    cart.gift_card_id = None
    cart.wrap_id = None
    cart.gift_from = ""
    cart.gift_to = ""
    cart.gift_message = ""
    set_addon_ids(cart, [])
    await touch_cart(cart)

    return serialize_order(order)


@router.get("", response_model=Page)
async def list_orders(
    user: CurrentUser,
    page: int = 1,
    page_size: int = 20,
) -> Page:
    page = max(1, page)
    page_size = min(max(1, page_size), 100)
    rows = await Order.find(Order.user_id == user.id).sort("-id").to_list()
    total = len(rows)
    chunk = rows[(page - 1) * page_size : (page - 1) * page_size + page_size]
    return Page(
        items=[serialize_order(o).model_dump() for o in chunk],
        total=total,
        page=page,
        page_size=page_size,
    )


@router.get("/{order_id}", response_model=OrderOut)
async def get_order(order_id: int, user: CurrentUser) -> OrderOut:
    order = await Order.find_one(Order.id == order_id, Order.user_id == user.id)
    if order is None:
        raise AppError(404, "Order not found", code="ORDER_NOT_FOUND")
    return serialize_order(order)


@router.post("/{order_id}/reorder", response_model=OkOut)
async def reorder(order_id: int, user: CurrentUser) -> OkOut:
    from app.services.pricing import new_cart_item_id

    order = await Order.find_one(Order.id == order_id, Order.user_id == user.id)
    if order is None:
        raise AppError(404, "Order not found", code="ORDER_NOT_FOUND")
    cart = await get_or_create_cart(user.id)
    for item in order.items:
        if item.product_id is None:
            continue
        product = await Product.find_one(Product.id == item.product_id)
        if product is None or product.status != "active":
            continue
        existing = next((i for i in cart.items if i.product_id == product.id), None)
        if existing:
            existing.qty += item.qty
            existing.unit_price = product.price
        else:
            cart.items.append(
                CartItemEmbed(
                    id=await new_cart_item_id(),
                    product_id=product.id,
                    qty=item.qty,
                    unit_price=product.price,
                )
            )
    await touch_cart(cart)
    return OkOut()
