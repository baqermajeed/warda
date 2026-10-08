from __future__ import annotations

from beanie.operators import In

from fastapi import APIRouter

from app.deps import CurrentUser
from app.errors import AppError
from app.models import AddonOption, CartItemEmbed, GiftCardOption, Product, WrapOption
from app.schemas import (
    CartItemIn,
    CartItemUpdateIn,
    CartOptionsIn,
    CartOut,
    OkOut,
    OptionOut,
)
from app.services.pricing import (
    calc_pricing,
    get_or_create_cart,
    new_cart_item_id,
    set_addon_ids,
    touch_cart,
)

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


async def serialize_cart(cart) -> CartOut:
    pricing = await calc_pricing(cart)
    product_ids = [i.product_id for i in cart.items]
    products: dict[int, Product] = {}
    if product_ids:
        rows = await Product.find(In(Product.id, product_ids)).to_list()
        products = {p.id: p for p in rows if p.id is not None}
    items = []
    for item in cart.items:
        p = products.get(item.product_id)
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
    gift_card = pricing.get("gift_card")
    wrap = pricing.get("wrap")
    return CartOut(
        items=items,
        gift_card=_option_out(gift_card) if gift_card else None,
        wrap=_option_out(wrap) if wrap else None,
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
async def get_cart(user: CurrentUser) -> CartOut:
    cart = await get_or_create_cart(user.id)
    return await serialize_cart(cart)


@router.post("/cart/items", response_model=CartOut)
async def add_item(payload: CartItemIn, user: CurrentUser) -> CartOut:
    product = await Product.find_one(Product.id == payload.product_id)
    if product is None or product.status != "active":
        raise AppError(404, "Product not found", code="PRODUCT_NOT_FOUND")
    cart = await get_or_create_cart(user.id)
    existing = next((i for i in cart.items if i.product_id == product.id), None)
    if existing:
        existing.qty += payload.qty
        existing.unit_price = product.price
    else:
        cart.items.append(
            CartItemEmbed(
                id=await new_cart_item_id(),
                product_id=product.id,
                qty=payload.qty,
                unit_price=product.price,
            )
        )
    await touch_cart(cart)
    cart = await get_or_create_cart(user.id)
    return await serialize_cart(cart)


@router.patch("/cart/items/{item_id}", response_model=CartOut)
async def update_item(
    item_id: int, payload: CartItemUpdateIn, user: CurrentUser
) -> CartOut:
    cart = await get_or_create_cart(user.id)
    item = next((i for i in cart.items if i.id == item_id), None)
    if item is None:
        raise AppError(404, "Cart item not found", code="CART_ITEM_NOT_FOUND")
    if payload.qty <= 0:
        cart.items = [i for i in cart.items if i.id != item_id]
    else:
        item.qty = payload.qty
    await touch_cart(cart)
    cart = await get_or_create_cart(user.id)
    return await serialize_cart(cart)


@router.delete("/cart/items/{item_id}", response_model=CartOut)
async def delete_item(item_id: int, user: CurrentUser) -> CartOut:
    cart = await get_or_create_cart(user.id)
    cart.items = [i for i in cart.items if i.id != item_id]
    await touch_cart(cart)
    cart = await get_or_create_cart(user.id)
    return await serialize_cart(cart)


@router.delete("/cart", response_model=OkOut)
async def clear_cart(user: CurrentUser) -> OkOut:
    cart = await get_or_create_cart(user.id)
    cart.items = []
    cart.gift_card_id = None
    cart.wrap_id = None
    cart.gift_from = ""
    cart.gift_to = ""
    cart.gift_message = ""
    set_addon_ids(cart, [])
    await touch_cart(cart)
    return OkOut()


@router.put("/cart/options", response_model=CartOut)
async def update_options(payload: CartOptionsIn, user: CurrentUser) -> CartOut:
    cart = await get_or_create_cart(user.id)
    if payload.gift_card_id is not None:
        card = await GiftCardOption.find_one(GiftCardOption.id == payload.gift_card_id)
        if card is None or not card.is_active:
            raise AppError(400, "Invalid gift card", code="INVALID_GIFT_CARD")
        cart.gift_card_id = card.id
    else:
        cart.gift_card_id = None

    if payload.wrap_id is not None:
        wrap = await WrapOption.find_one(WrapOption.id == payload.wrap_id)
        if wrap is None or not wrap.is_active:
            raise AppError(400, "Invalid wrap", code="INVALID_WRAP")
        cart.wrap_id = wrap.id
    else:
        cart.wrap_id = None

    if payload.addon_ids:
        found = await AddonOption.find(
            In(AddonOption.id, payload.addon_ids),
            AddonOption.is_active == True,  # noqa: E712
        ).to_list()
        if len(found) != len(set(payload.addon_ids)):
            raise AppError(400, "Invalid addons", code="INVALID_ADDONS")
    set_addon_ids(cart, payload.addon_ids)
    cart.gift_from = payload.gift_from
    cart.gift_to = payload.gift_to
    cart.gift_message = payload.gift_message
    await touch_cart(cart)
    cart = await get_or_create_cart(user.id)
    return await serialize_cart(cart)


@router.get("/gift-cards", response_model=list[OptionOut])
async def gift_cards() -> list[OptionOut]:
    rows = (
        await GiftCardOption.find(GiftCardOption.is_active == True)  # noqa: E712
        .sort("+id")
        .to_list()
    )
    return [_option_out(r) for r in rows]


@router.get("/wraps", response_model=list[OptionOut])
async def wraps() -> list[OptionOut]:
    rows = (
        await WrapOption.find(WrapOption.is_active == True)  # noqa: E712
        .sort("+id")
        .to_list()
    )
    return [_option_out(r) for r in rows]


@router.get("/addons", response_model=list[OptionOut])
async def addons(category: str | None = None) -> list[OptionOut]:
    query = AddonOption.find(AddonOption.is_active == True)  # noqa: E712
    if category and category != "all":
        query = AddonOption.find(
            AddonOption.is_active == True,  # noqa: E712
            AddonOption.category == category,
        )
    rows = await query.sort("+id").to_list()
    return [_option_out(r, with_category=True) for r in rows]
