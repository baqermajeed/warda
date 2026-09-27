from __future__ import annotations

from fastapi import APIRouter
from sqlalchemy import select

from app.deps import CurrentUser, DbSession
from app.errors import AppError
from app.models import AddonOption, CartItem, GiftCardOption, Product, WrapOption
from app.schemas import (
    CartItemIn,
    CartItemUpdateIn,
    CartOptionsIn,
    CartOut,
    OkOut,
    OptionOut,
)
from app.services.auth_tokens import parse_json_list
from app.services.pricing import calc_pricing, get_or_create_cart, set_addon_ids

router = APIRouter(tags=["cart"])


def _option_out(obj, *, with_category: bool = False) -> OptionOut:
    return OptionOut(
        id=obj.id,
        code=obj.code,
        title_ar=obj.title_ar,
        title_en=obj.title_en,
        price=obj.price,
        image=obj.image,
        category=getattr(obj, "category", None) if with_category else None,
    )


def serialize_cart(db: DbSession, cart) -> CartOut:
    pricing = calc_pricing(db, cart)
    items = []
    for item in cart.items:
        p = item.product
        items.append(
            {
                "id": item.id,
                "product_id": item.product_id,
                "title_ar": p.title_ar if p else "",
                "title_en": p.title_en if p else "",
                "image": p.cover_image if p else None,
                "unit_price": item.unit_price,
                "qty": item.qty,
                "line_total": item.unit_price * item.qty,
            }
        )
    return CartOut(
        items=items,
        gift_card=_option_out(cart.gift_card) if cart.gift_card else None,
        wrap=_option_out(cart.wrap) if cart.wrap else None,
        addons=[_option_out(a, with_category=True) for a in pricing["addons"]],
        gift_from=cart.gift_from,
        gift_to=cart.gift_to,
        gift_message=cart.gift_message,
        pricing={
            "subtotal": pricing["subtotal"],
            "wrap_price": pricing["wrap_price"],
            "addons_price": pricing["addons_price"],
            "card_price": pricing["card_price"],
            "delivery_price": pricing["delivery_price"],
            "total": pricing["total"],
            "has_free_delivery": pricing["has_free_delivery"],
        },
    )


@router.get("/cart", response_model=CartOut)
def get_cart(db: DbSession, user: CurrentUser) -> CartOut:
    cart = get_or_create_cart(db, user.id)
    return serialize_cart(db, cart)


@router.post("/cart/items", response_model=CartOut)
def add_item(payload: CartItemIn, db: DbSession, user: CurrentUser) -> CartOut:
    product = db.get(Product, payload.product_id)
    if product is None or product.status != "active":
        raise AppError(404, "Product not found", code="PRODUCT_NOT_FOUND")
    cart = get_or_create_cart(db, user.id)
    existing = next((i for i in cart.items if i.product_id == product.id), None)
    if existing:
        existing.qty += payload.qty
        existing.unit_price = product.price
    else:
        db.add(
            CartItem(
                cart_id=cart.id,
                product_id=product.id,
                qty=payload.qty,
                unit_price=product.price,
            )
        )
    db.commit()
    cart = get_or_create_cart(db, user.id)
    return serialize_cart(db, cart)


@router.patch("/cart/items/{item_id}", response_model=CartOut)
def update_item(item_id: int, payload: CartItemUpdateIn, db: DbSession, user: CurrentUser) -> CartOut:
    cart = get_or_create_cart(db, user.id)
    item = next((i for i in cart.items if i.id == item_id), None)
    if item is None:
        raise AppError(404, "Cart item not found", code="CART_ITEM_NOT_FOUND")
    if payload.qty <= 0:
        db.delete(item)
    else:
        item.qty = payload.qty
    db.commit()
    cart = get_or_create_cart(db, user.id)
    return serialize_cart(db, cart)


@router.delete("/cart/items/{item_id}", response_model=CartOut)
def delete_item(item_id: int, db: DbSession, user: CurrentUser) -> CartOut:
    cart = get_or_create_cart(db, user.id)
    item = next((i for i in cart.items if i.id == item_id), None)
    if item:
        db.delete(item)
        db.commit()
    cart = get_or_create_cart(db, user.id)
    return serialize_cart(db, cart)


@router.delete("/cart", response_model=OkOut)
def clear_cart(db: DbSession, user: CurrentUser) -> OkOut:
    cart = get_or_create_cart(db, user.id)
    for item in list(cart.items):
        db.delete(item)
    cart.gift_card_id = None
    cart.wrap_id = None
    cart.gift_from = ""
    cart.gift_to = ""
    cart.gift_message = ""
    set_addon_ids(cart, [])
    db.commit()
    return OkOut()


@router.put("/cart/options", response_model=CartOut)
def update_options(payload: CartOptionsIn, db: DbSession, user: CurrentUser) -> CartOut:
    cart = get_or_create_cart(db, user.id)
    if payload.gift_card_id is not None:
        card = db.get(GiftCardOption, payload.gift_card_id)
        if card is None or not card.is_active:
            raise AppError(400, "Invalid gift card", code="INVALID_GIFT_CARD")
        cart.gift_card_id = card.id
    else:
        cart.gift_card_id = None

    if payload.wrap_id is not None:
        wrap = db.get(WrapOption, payload.wrap_id)
        if wrap is None or not wrap.is_active:
            raise AppError(400, "Invalid wrap", code="INVALID_WRAP")
        cart.wrap_id = wrap.id
    else:
        cart.wrap_id = None

    if payload.addon_ids:
        found = db.scalars(
            select(AddonOption).where(
                AddonOption.id.in_(payload.addon_ids),
                AddonOption.is_active.is_(True),
            )
        ).all()
        if len(found) != len(set(payload.addon_ids)):
            raise AppError(400, "Invalid addons", code="INVALID_ADDONS")
    set_addon_ids(cart, payload.addon_ids)
    cart.gift_from = payload.gift_from
    cart.gift_to = payload.gift_to
    cart.gift_message = payload.gift_message
    db.commit()
    cart = get_or_create_cart(db, user.id)
    return serialize_cart(db, cart)


@router.get("/gift-cards", response_model=list[OptionOut])
def gift_cards(db: DbSession) -> list[OptionOut]:
    rows = db.scalars(
        select(GiftCardOption).where(GiftCardOption.is_active.is_(True)).order_by(GiftCardOption.id)
    ).all()
    return [_option_out(r) for r in rows]


@router.get("/wraps", response_model=list[OptionOut])
def wraps(db: DbSession) -> list[OptionOut]:
    rows = db.scalars(
        select(WrapOption).where(WrapOption.is_active.is_(True)).order_by(WrapOption.id)
    ).all()
    return [_option_out(r) for r in rows]


@router.get("/addons", response_model=list[OptionOut])
def addons(db: DbSession, category: str | None = None) -> list[OptionOut]:
    stmt = select(AddonOption).where(AddonOption.is_active.is_(True)).order_by(AddonOption.id)
    if category and category != "all":
        stmt = stmt.where(AddonOption.category == category)
    rows = db.scalars(stmt).all()
    return [_option_out(r, with_category=True) for r in rows]
