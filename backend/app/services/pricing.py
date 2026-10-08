from __future__ import annotations

import json

from beanie.operators import In

from app.config import settings, utcnow
from app.db import next_seq
from app.models import AddonOption, Cart, CartItemEmbed, GiftCardOption, WrapOption
from app.services.auth_tokens import parse_json_list


async def get_or_create_cart(user_id: int) -> Cart:
    cart = await Cart.find_one(Cart.user_id == user_id)
    if cart is None:
        cart = Cart(user_id=user_id)
        await cart.insert()
    return cart


async def calc_pricing(cart: Cart) -> dict:
    subtotal = sum(item.unit_price * item.qty for item in cart.items)
    wrap = (
        await WrapOption.find_one(WrapOption.id == cart.wrap_id)
        if cart.wrap_id
        else None
    )
    gift_card = (
        await GiftCardOption.find_one(GiftCardOption.id == cart.gift_card_id)
        if cart.gift_card_id
        else None
    )
    wrap_price = wrap.price if wrap else 0
    card_price = gift_card.price if gift_card else 0

    addon_ids = parse_json_list(cart.addon_ids_json)
    addons: list[AddonOption] = []
    addons_price = 0
    if addon_ids:
        addons = await AddonOption.find(
            In(AddonOption.id, addon_ids),
            AddonOption.is_active == True,  # noqa: E712
        ).to_list()
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
        "wrap": wrap,
        "gift_card": gift_card,
    }


def set_addon_ids(cart: Cart, addon_ids: list[int]) -> None:
    cart.addon_ids_json = json.dumps(sorted(set(addon_ids)))


async def new_cart_item_id() -> int:
    return await next_seq("cart_items")


async def touch_cart(cart: Cart) -> None:
    cart.updated_at = utcnow()
    await cart.save()
