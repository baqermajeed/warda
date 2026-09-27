from __future__ import annotations

from fastapi import APIRouter
from sqlalchemy import func, or_, select
from sqlalchemy.orm import selectinload

from app.cache import cache_json_get, cache_json_set
from app.deps import CurrentUser, DbSession, OptionalUser
from app.errors import AppError
from app.models import Banner, Category, Favorite, Product
from app.schemas import (
    CategoryOut,
    HomeOut,
    Page,
    ProductCardOut,
    ProductDetailOut,
)
from app.services.serializers import product_card, product_detail

router = APIRouter(tags=["catalog"])


def _favorite_ids(db: DbSession, user_id: int | None) -> set[int]:
    if user_id is None:
        return set()
    rows = db.scalars(select(Favorite.product_id).where(Favorite.user_id == user_id)).all()
    return set(rows)


@router.get("/home", response_model=HomeOut)
def home(db: DbSession, user: OptionalUser) -> HomeOut:
    favs = _favorite_ids(db, user.id if user else None)
    cached = cache_json_get("home:v1")
    if cached and user is None:
        return HomeOut(**cached)

    banners = db.scalars(
        select(Banner).where(Banner.is_active.is_(True)).order_by(Banner.sort_order, Banner.id)
    ).all()
    categories = db.scalars(
        select(Category)
        .where(Category.is_active.is_(True), Category.parent_id.is_(None))
        .order_by(Category.sort_order, Category.id)
        .limit(12)
    ).all()
    latest = db.scalars(
        select(Product)
        .where(Product.status == "active", Product.is_latest.is_(True))
        .order_by(Product.id.desc())
        .limit(12)
    ).all()
    popular = db.scalars(
        select(Product)
        .where(Product.status == "active", Product.is_popular.is_(True))
        .order_by(Product.id.desc())
        .limit(12)
    ).all()
    all_gifts = db.scalars(
        select(Product).where(Product.status == "active").order_by(Product.id.desc()).limit(20)
    ).all()

    payload = HomeOut(
        banners=[
            {
                "id": b.id,
                "title_ar": b.title_ar,
                "title_en": b.title_en,
                "image": b.image,
                "link": b.link,
            }
            for b in banners
        ],
        categories=[CategoryOut.model_validate(c) for c in categories],
        latest=[product_card(p, favorite_ids=favs) for p in latest],
        popular=[product_card(p, favorite_ids=favs) for p in popular],
        all_gifts=[product_card(p, favorite_ids=favs) for p in all_gifts],
    )
    if user is None:
        cache_json_set("home:v1", payload.model_dump(), 30)
    return payload


@router.get("/categories", response_model=list[CategoryOut])
def categories(db: DbSession) -> list[CategoryOut]:
    rows = db.scalars(
        select(Category)
        .where(Category.is_active.is_(True))
        .order_by(Category.sort_order, Category.id)
    ).all()
    return [CategoryOut.model_validate(c) for c in rows]


@router.get("/products", response_model=Page)
def list_products(
    db: DbSession,
    user: OptionalUser,
    q: str | None = None,
    person: str | None = None,
    occasion: str | None = None,
    gift_type: str | None = None,
    budget: str | None = None,
    delivery: str | None = None,
    category_id: int | None = None,
    sort: str = "newest",
    page: int = 1,
    page_size: int = 20,
) -> Page:
    page = max(1, page)
    page_size = min(max(1, page_size), 100)
    favs = _favorite_ids(db, user.id if user else None)

    stmt = select(Product).where(Product.status == "active")
    if q:
        like = f"%{q.strip()}%"
        stmt = stmt.where(
            or_(Product.title_ar.ilike(like), Product.title_en.ilike(like), Product.sku.ilike(like))
        )
    if person:
        stmt = stmt.where(Product.person_tag == person)
    if occasion:
        stmt = stmt.where(Product.occasion_tag == occasion)
    if gift_type:
        stmt = stmt.where(Product.gift_type_tag == gift_type)
    if budget:
        stmt = stmt.where(Product.budget_tag == budget)
    if delivery:
        stmt = stmt.where(Product.delivery_tag == delivery)
    if category_id:
        stmt = stmt.where(Product.category_id == category_id)

    count_stmt = select(func.count()).select_from(stmt.subquery())
    total = db.scalar(count_stmt) or 0

    if sort == "priceAsc":
        stmt = stmt.order_by(Product.price.asc())
    elif sort == "priceDesc":
        stmt = stmt.order_by(Product.price.desc())
    elif sort == "popular":
        stmt = stmt.order_by(Product.is_popular.desc(), Product.id.desc())
    else:
        stmt = stmt.order_by(Product.id.desc())

    rows = db.scalars(stmt.offset((page - 1) * page_size).limit(page_size)).all()
    return Page(
        items=[product_card(p, favorite_ids=favs).model_dump() for p in rows],
        total=total,
        page=page,
        page_size=page_size,
    )


@router.get("/products/{product_id}", response_model=ProductDetailOut)
def get_product(product_id: int, db: DbSession, user: OptionalUser) -> ProductDetailOut:
    product = db.scalars(
        select(Product)
        .where(Product.id == product_id, Product.status == "active")
        .options(selectinload(Product.images))
    ).first()
    if product is None:
        raise AppError(404, "Product not found", code="PRODUCT_NOT_FOUND")
    favs = _favorite_ids(db, user.id if user else None)
    similar = db.scalars(
        select(Product)
        .where(
            Product.status == "active",
            Product.id != product.id,
            Product.gift_type_tag == product.gift_type_tag,
        )
        .limit(8)
    ).all()
    if not similar:
        similar = db.scalars(
            select(Product)
            .where(Product.status == "active", Product.id != product.id)
            .order_by(Product.id.desc())
            .limit(8)
        ).all()
    return product_detail(product, similar=list(similar), favorite_ids=favs)


@router.get("/lookups")
def lookups() -> dict:
    cached = cache_json_get("lookups:v1")
    if cached:
        return cached
    data = {
        "governorates": [
            "gov_baghdad",
            "gov_basra",
            "gov_nineveh",
            "gov_erbil",
            "gov_najaf",
            "gov_karbala",
            "gov_anbar",
            "gov_diyala",
            "gov_wasit",
            "gov_maysan",
            "gov_muthanna",
            "gov_qadisiyyah",
            "gov_dhi_qar",
            "gov_saladin",
            "gov_kirkuk",
            "gov_duhok",
            "gov_sulaymaniyah",
            "gov_babylon",
        ],
        "person": ["parents", "sibling", "spouse", "friends", "work", "kids", "grandparents", "other"],
        "occasion": [
            "birthday",
            "wedding",
            "graduation",
            "thanks",
            "newborn",
            "fathers",
            "mothers",
            "love",
            "formal",
            "none",
        ],
        "gift_type": [
            "flowers",
            "cake",
            "chocolate",
            "plants",
            "jewelry",
            "candles",
            "home",
            "men",
            "women",
            "care",
            "toys",
        ],
        "budget": ["b1", "b2", "b3", "b4"],
        "delivery": ["same_day", "tomorrow", "pickup"],
        "sort": ["newest", "priceAsc", "priceDesc", "popular"],
        "payment_methods": ["cod", "card"],
        "currency": "IQD",
        "free_delivery_threshold": 100000,
        "delivery_fee": 5000,
    }
    cache_json_set("lookups:v1", data, 300)
    return data
