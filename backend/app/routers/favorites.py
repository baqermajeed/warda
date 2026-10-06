from __future__ import annotations

from fastapi import APIRouter
from sqlalchemy import select
from sqlalchemy.orm import selectinload

from app.deps import CurrentUser, DbSession
from app.errors import AppError
from app.models import Favorite, Product
from app.schemas import OkOut, Page
from app.services.serializers import product_card
from app.services.taxonomy import gift_type_tags

router = APIRouter(prefix="/favorites", tags=["favorites"])


@router.get("", response_model=Page)
def list_favorites(
    db: DbSession,
    user: CurrentUser,
    page: int = 1,
    page_size: int = 20,
    category: str | None = None,
) -> Page:
    page = max(1, page)
    page_size = min(max(1, page_size), 100)
    stmt = (
        select(Favorite)
        .where(Favorite.user_id == user.id)
        .options(selectinload(Favorite.product))
        .order_by(Favorite.id.desc())
    )
    rows = db.scalars(stmt).all()
    products = [f.product for f in rows if f.product and f.product.status == "active"]
    if category and category != "all":
        tags = set(gift_type_tags(category))
        products = [p for p in products if p.gift_type_tag in tags]
    total = len(products)
    start = (page - 1) * page_size
    chunk = products[start : start + page_size]
    fav_ids = {p.id for p in chunk}
    return Page(
        items=[product_card(p, favorite_ids=fav_ids).model_dump() for p in chunk],
        total=total,
        page=page,
        page_size=page_size,
    )


@router.put("/{product_id}", response_model=OkOut)
def add_favorite(product_id: int, db: DbSession, user: CurrentUser) -> OkOut:
    product = db.get(Product, product_id)
    if product is None or product.status != "active":
        raise AppError(404, "Product not found", code="PRODUCT_NOT_FOUND")
    existing = db.scalars(
        select(Favorite).where(Favorite.user_id == user.id, Favorite.product_id == product_id)
    ).first()
    if existing is None:
        db.add(Favorite(user_id=user.id, product_id=product_id))
        db.commit()
    return OkOut()


@router.delete("/{product_id}", response_model=OkOut)
def remove_favorite(product_id: int, db: DbSession, user: CurrentUser) -> OkOut:
    row = db.scalars(
        select(Favorite).where(Favorite.user_id == user.id, Favorite.product_id == product_id)
    ).first()
    if row:
        db.delete(row)
        db.commit()
    return OkOut()
