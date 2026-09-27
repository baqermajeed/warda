from __future__ import annotations

import json

from sqlalchemy import select
from sqlalchemy.orm import Session, selectinload

from app.config import settings
from app.models import AddonOption, Cart, CartItem, GiftCardOption, Product, WrapOption
from app.services.auth_tokens import parse_json_list


def get_or_create_cart(db: Session, user_id: int) -> Cart:
    cart = db.scalars(
        select(Cart)
        .where(Cart.user_id == user_id)
        .options(
            selectinload(Cart.items).selectinload(CartItem.product),
            selectinload(Cart.gift_card),
            selectinload(Cart.wrap),
        )
    ).first()
    if cart is None:
        cart = Cart(user_id=user_id)
        db.add(cart)
        db.commit()
        db.refresh(cart)
        cart = db.scalars(
            select(Cart)
            .where(Cart.id == cart.id)
            .options(
                selectinload(Cart.items).selectinload(CartItem.product),
                selectinload(Cart.gift_card),
                selectinload(Cart.wrap),
            )
        ).one()
    return cart


def calc_pricing(db: Session, cart: Cart) -> dict:
    subtotal = sum(item.unit_price * item.qty for item in cart.items)
    wrap_price = cart.wrap.price if cart.wrap else 0
    card_price = cart.gift_card.price if cart.gift_card else 0

    addon_ids = parse_json_list(cart.addon_ids_json)
    addons_price = 0
    addons: list[AddonOption] = []
    if addon_ids:
        addons = list(
            db.scalars(
                select(AddonOption).where(
                    AddonOption.id.in_(addon_ids),
                    AddonOption.is_active.is_(True),
                )
            ).all()
        )
        addons_price = sum(a.price for a in addons)

    delivery = 0 if subtotal >= settings.free_delivery_threshold else settings.delivery_fee
    if subtotal == 0:
        delivery = 0
    total = subtotal + wrap_price + addons_price + card_price + delivery
    return {
        "subtotal": subtotal,
        "wrap_price": wrap_price,
        "addons_price": addons_price,
        "card_price": card_price,
        "delivery_price": delivery,
        "total": total,
        "has_free_delivery": delivery == 0 and subtotal > 0,
        "addons": addons,
    }


def set_addon_ids(cart: Cart, addon_ids: list[int]) -> None:
    cart.addon_ids_json = json.dumps(sorted(set(addon_ids)))
