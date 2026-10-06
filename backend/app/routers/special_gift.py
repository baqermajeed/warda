from __future__ import annotations

from fastapi import APIRouter
from sqlalchemy import and_, select

from app.deps import DbSession, OptionalUser
from app.models import Favorite, Product
from app.schemas import Page, SpecialGiftRecommendIn
from app.services.serializers import product_card
from app.services.taxonomy import (
    SPECIAL_GIFT_OCCASIONS,
    SPECIAL_GIFT_RECIPIENTS,
    SPECIAL_GIFT_TYPES,
    gift_type_tags,
    occasion_tags,
)

router = APIRouter(prefix="/special-gift", tags=["special-gift"])


@router.get("/options")
def options() -> dict:
    return {
        "recipients": SPECIAL_GIFT_RECIPIENTS,
        "occasions": SPECIAL_GIFT_OCCASIONS,
        "types": SPECIAL_GIFT_TYPES,
    }


@router.post("/recommend", response_model=Page)
def recommend(
    payload: SpecialGiftRecommendIn,
    db: DbSession,
    user: OptionalUser,
    page: int = 1,
    page_size: int = 20,
) -> Page:
    page = max(1, page)
    page_size = min(max(1, page_size), 100)
    filters = [Product.status == "active"]
    if payload.recipient_id:
        filters.append(Product.person_tag == payload.recipient_id)
    if payload.occasion_id and payload.occasion_id != "none":
        filters.append(Product.occasion_tag.in_(occasion_tags(payload.occasion_id)))
    if payload.type_id:
        filters.append(Product.gift_type_tag.in_(gift_type_tags(payload.type_id)))
    if payload.budget_from is not None:
        filters.append(Product.price >= payload.budget_from)
    if payload.budget_to is not None:
        filters.append(Product.price <= payload.budget_to)

    stmt = select(Product).where(and_(*filters)).order_by(Product.is_popular.desc(), Product.id.desc())
    rows = list(db.scalars(stmt).all())
    # Soft fallback if filters too strict
    if not rows:
        soft = [Product.status == "active"]
        if payload.type_id:
            soft.append(Product.gift_type_tag.in_(gift_type_tags(payload.type_id)))
        rows = list(
            db.scalars(
                select(Product)
                .where(and_(*soft))
                .order_by(Product.is_popular.desc(), Product.id.desc())
                .limit(40)
            ).all()
        )

    favs: set[int] = set()
    if user:
        favs = set(
            db.scalars(select(Favorite.product_id).where(Favorite.user_id == user.id)).all()
        )
    total = len(rows)
    chunk = rows[(page - 1) * page_size : (page - 1) * page_size + page_size]
    return Page(
        items=[product_card(p, favorite_ids=favs).model_dump() for p in chunk],
        total=total,
        page=page,
        page_size=page_size,
    )
