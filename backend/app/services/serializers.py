from __future__ import annotations

import json

from app.models import Product
from app.schemas import ProductCardOut, ProductDetailOut


def money_label(value: int) -> str:
    s = f"{value:,}"
    return s


def product_card(product: Product, *, favorite_ids: set[int] | None = None) -> ProductCardOut:
    favs = favorite_ids or set()
    return ProductCardOut(
        id=product.id,
        title=product.title_ar,
        title_ar=product.title_ar,
        title_en=product.title_en,
        price=product.price,
        price_label=money_label(product.price),
        rating=product.rating,
        image=product.cover_image,
        is_favorite=product.id in favs,
        person_tag=product.person_tag,
        occasion_tag=product.occasion_tag,
        gift_type_tag=product.gift_type_tag,
    )


def product_detail(
    product: Product,
    *,
    similar: list[Product],
    favorite_ids: set[int] | None = None,
) -> ProductDetailOut:
    card = product_card(product, favorite_ids=favorite_ids)
    images = [img.url for img in sorted(product.images, key=lambda i: i.sort_order)]
    if product.cover_image and product.cover_image not in images:
        images = [product.cover_image, *images]
    try:
        care_ar = json.loads(product.care_steps_ar or "[]")
    except Exception:
        care_ar = []
    try:
        care_en = json.loads(product.care_steps_en or "[]")
    except Exception:
        care_en = []
    try:
        badges = json.loads(product.badges_json or "[]")
    except Exception:
        badges = []
    return ProductDetailOut(
        **card.model_dump(),
        description_ar=product.description_ar,
        description_en=product.description_en,
        images=images,
        height_label=product.height_label,
        width_label=product.width_label,
        care_steps_ar=care_ar if isinstance(care_ar, list) else [],
        care_steps_en=care_en if isinstance(care_en, list) else [],
        badges=badges if isinstance(badges, list) else [],
        similar=[product_card(p, favorite_ids=favorite_ids) for p in similar],
    )
