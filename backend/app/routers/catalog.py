from __future__ import annotations

from beanie.operators import Or, RegEx

from fastapi import APIRouter

from app.cache import cache_json_get, cache_json_set
from app.deps import CurrentUser, OptionalUser
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


async def _favorite_ids(user_id: int | None) -> set[int]:
    if user_id is None:
        return set()
    rows = await Favorite.find(Favorite.user_id == user_id).to_list()
    return {r.product_id for r in rows}


@router.get("/home", response_model=HomeOut)
async def home(user: OptionalUser) -> HomeOut:
    favs = await _favorite_ids(user.id if user else None)
    cached = cache_json_get("home:v1")
    if cached and user is None:
        return HomeOut(**cached)

    banners = (
        await Banner.find(Banner.is_active == True)  # noqa: E712
        .sort("+sort_order", "+id")
        .to_list()
    )
    categories = (
        await Category.find(
            Category.is_active == True,  # noqa: E712
            Category.parent_id == None,  # noqa: E711
        )
        .sort("+sort_order", "+id")
        .limit(12)
        .to_list()
    )
    latest = (
        await Product.find(Product.status == "active", Product.is_latest == True)  # noqa: E712
        .sort("-id")
        .limit(12)
        .to_list()
    )
    popular = (
        await Product.find(Product.status == "active", Product.is_popular == True)  # noqa: E712
        .sort("-id")
        .limit(12)
        .to_list()
    )
    all_gifts = (
        await Product.find(Product.status == "active").sort("-id").limit(20).to_list()
    )

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
async def categories() -> list[CategoryOut]:
    rows = (
        await Category.find(Category.is_active == True)  # noqa: E712
        .sort("+sort_order", "+id")
        .to_list()
    )
    return [CategoryOut.model_validate(c) for c in rows]


@router.get("/products", response_model=Page)
async def list_products(
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
    favs = await _favorite_ids(user.id if user else None)

    filters = [Product.status == "active"]
    if q:
        term = q.strip()
        filters.append(
            Or(
                RegEx(Product.title_ar, term, "i"),
                RegEx(Product.title_en, term, "i"),
                RegEx(Product.sku, term, "i"),
            )
        )
    if person:
        filters.append(Product.person_tag == person)
    if occasion:
        filters.append(Product.occasion_tag == occasion)
    if gift_type:
        filters.append(Product.gift_type_tag == gift_type)
    if budget:
        filters.append(Product.budget_tag == budget)
    if delivery:
        filters.append(Product.delivery_tag == delivery)
    if category_id:
        filters.append(Product.category_id == category_id)

    base = Product.find(*filters)
    total = await base.count()

    if sort == "priceAsc":
        query = base.sort("+price")
    elif sort == "priceDesc":
        query = base.sort("-price")
    elif sort == "popular":
        query = base.sort("-is_popular", "-id")
    else:
        query = base.sort("-id")

    rows = await query.skip((page - 1) * page_size).limit(page_size).to_list()
    return Page(
        items=[product_card(p, favorite_ids=favs).model_dump() for p in rows],
        total=total,
        page=page,
        page_size=page_size,
    )


@router.get("/products/{product_id}", response_model=ProductDetailOut)
async def get_product(product_id: int, user: OptionalUser) -> ProductDetailOut:
    product = await Product.find_one(Product.id == product_id, Product.status == "active")
    if product is None:
        raise AppError(404, "Product not found", code="PRODUCT_NOT_FOUND")
    favs = await _favorite_ids(user.id if user else None)
    similar = (
        await Product.find(
            Product.status == "active",
            Product.id != product.id,
            Product.gift_type_tag == product.gift_type_tag,
        )
        .limit(8)
        .to_list()
    )
    if not similar:
        similar = (
            await Product.find(Product.status == "active", Product.id != product.id)
            .sort("-id")
            .limit(8)
            .to_list()
        )
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
