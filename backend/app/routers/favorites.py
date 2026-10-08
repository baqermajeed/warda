from __future__ import annotations

from beanie.operators import In

from fastapi import APIRouter

from app.deps import CurrentUser
from app.errors import AppError
from app.models import Favorite, Product
from app.schemas import OkOut, Page
from app.services.serializers import product_card

router = APIRouter(prefix="/favorites", tags=["favorites"])


@router.get("", response_model=Page)
async def list_favorites(
    user: CurrentUser,
    page: int = 1,
    page_size: int = 20,
    category: str | None = None,
) -> Page:
    page = max(1, page)
    page_size = min(max(1, page_size), 100)
    rows = await Favorite.find(Favorite.user_id == user.id).sort("-id").to_list()
    product_ids = [f.product_id for f in rows]
    products_by_id: dict[int, Product] = {}
    if product_ids:
        prods = await Product.find(In(Product.id, product_ids)).to_list()
        products_by_id = {p.id: p for p in prods if p.id is not None}
    products = [
        products_by_id[f.product_id]
        for f in rows
        if f.product_id in products_by_id
        and products_by_id[f.product_id].status == "active"
    ]
    if category and category != "all":
        products = [p for p in products if p.gift_type_tag == category]
    total = len(products)
    start = (page - 1) * page_size
    chunk = products[start : start + page_size]
    fav_ids = {p.id for p in chunk if p.id is not None}
    return Page(
        items=[product_card(p, favorite_ids=fav_ids).model_dump() for p in chunk],
        total=total,
        page=page,
        page_size=page_size,
    )


@router.put("/{product_id}", response_model=OkOut)
async def add_favorite(product_id: int, user: CurrentUser) -> OkOut:
    product = await Product.find_one(Product.id == product_id)
    if product is None or product.status != "active":
        raise AppError(404, "Product not found", code="PRODUCT_NOT_FOUND")
    existing = await Favorite.find_one(
        Favorite.user_id == user.id,
        Favorite.product_id == product_id,
    )
    if existing is None:
        await Favorite(user_id=user.id, product_id=product_id).insert()
    return OkOut()


@router.delete("/{product_id}", response_model=OkOut)
async def remove_favorite(product_id: int, user: CurrentUser) -> OkOut:
    row = await Favorite.find_one(
        Favorite.user_id == user.id,
        Favorite.product_id == product_id,
    )
    if row:
        await row.delete()
    return OkOut()
