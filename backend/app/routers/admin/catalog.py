"""Admin: categories, banners, products (gifts) and basket options."""

from __future__ import annotations

import json

from fastapi import APIRouter
from sqlalchemy import delete, func, or_, select, update
from sqlalchemy.orm import selectinload

from app.deps import AdminUser, DbSession
from app.errors import AppError
from app.models import (
    AddonOption,
    Banner,
    Cart,
    CartItem,
    Category,
    Favorite,
    GiftCardOption,
    OrderItem,
    Product,
    ProductImage,
    WrapOption,
)
from app.routers.admin.common import (
    apply_patch,
    bust_public_cache,
    ensure_unique,
    fill_english,
    get_or_404,
    iso,
    json_list,
    page_out,
    paginate,
)
from app.schemas import OkOut
from app.schemas.admin import (
    BannerIn,
    BannerPatch,
    CategoryIn,
    CategoryPatch,
    OptionIn,
    OptionPatch,
    ProductIn,
    ProductPatch,
)
from app.services.ranking import product_stats, with_popularity
from app.services.taxonomy import budget_for_price

router = APIRouter()


# ——— Categories ———


def _category_out(c: Category, product_count: int = 0) -> dict:
    return {
        "id": c.id,
        "slug": c.slug,
        "name_ar": c.name_ar,
        "name_en": c.name_en,
        "image": c.image,
        "sort_order": c.sort_order,
        "is_active": c.is_active,
        "product_count": product_count,
    }


@router.get("/categories")
def list_categories(db: DbSession, _admin: AdminUser) -> list[dict]:
    counts = dict(
        db.execute(
            select(Product.category_id, func.count(Product.id)).group_by(Product.category_id)
        ).all()
    )
    rows = db.scalars(select(Category).order_by(Category.sort_order, Category.id)).all()
    return [_category_out(c, counts.get(c.id, 0)) for c in rows]


@router.post("/categories")
def create_category(payload: CategoryIn, db: DbSession, _admin: AdminUser) -> dict:
    ensure_unique(db, Category, "slug", payload.slug)
    row = Category(**payload.model_dump())
    fill_english(row, "name")
    db.add(row)
    db.commit()
    bust_public_cache()
    return _category_out(row)


@router.patch("/categories/{category_id}")
def update_category(
    category_id: int, payload: CategoryPatch, db: DbSession, _admin: AdminUser
) -> dict:
    row = get_or_404(db, Category, category_id, "Category")
    if payload.slug:
        ensure_unique(db, Category, "slug", payload.slug, exclude_id=row.id)
    apply_patch(row, payload, required={"slug", "name_ar", "name_en", "sort_order", "is_active"})
    fill_english(row, "name")
    db.commit()
    bust_public_cache()
    return _category_out(row)


@router.delete("/categories/{category_id}", response_model=OkOut)
def delete_category(category_id: int, db: DbSession, _admin: AdminUser) -> OkOut:
    row = get_or_404(db, Category, category_id, "Category")
    # Gifts stay in the store, they just lose this category.
    db.execute(update(Product).where(Product.category_id == row.id).values(category_id=None))
    db.execute(update(Category).where(Category.parent_id == row.id).values(parent_id=None))
    db.delete(row)
    db.commit()
    bust_public_cache()
    return OkOut()


# ——— Banners ———


def _banner_out(b: Banner) -> dict:
    return {
        "id": b.id,
        "title_ar": b.title_ar,
        "title_en": b.title_en,
        "image": b.image,
        "link": b.link,
        "sort_order": b.sort_order,
        "is_active": b.is_active,
    }


@router.get("/banners")
def list_banners(db: DbSession, _admin: AdminUser) -> list[dict]:
    rows = db.scalars(select(Banner).order_by(Banner.sort_order, Banner.id)).all()
    return [_banner_out(b) for b in rows]


@router.post("/banners")
def create_banner(payload: BannerIn, db: DbSession, _admin: AdminUser) -> dict:
    row = Banner(**payload.model_dump())
    row.link = (row.link or "").strip() or None
    fill_english(row, "title")
    db.add(row)
    db.commit()
    bust_public_cache()
    return _banner_out(row)


@router.patch("/banners/{banner_id}")
def update_banner(banner_id: int, payload: BannerPatch, db: DbSession, _admin: AdminUser) -> dict:
    row = get_or_404(db, Banner, banner_id, "Banner")
    apply_patch(row, payload, required={"title_ar", "title_en", "image", "sort_order", "is_active"})
    row.link = (row.link or "").strip() or None
    fill_english(row, "title")
    db.commit()
    bust_public_cache()
    return _banner_out(row)


@router.delete("/banners/{banner_id}", response_model=OkOut)
def delete_banner(banner_id: int, db: DbSession, _admin: AdminUser) -> OkOut:
    db.delete(get_or_404(db, Banner, banner_id, "Banner"))
    db.commit()
    bust_public_cache()
    return OkOut()


# ——— Products ———


def _product_out(p: Product, stats: dict | None = None, *, full: bool = False) -> dict:
    stats = stats or {"sold": 0, "favorites": 0, "score": 0}
    out = {
        "id": p.id,
        "sku": p.sku,
        "title_ar": p.title_ar,
        "title_en": p.title_en,
        "price": p.price,
        "rating": p.rating,
        "category_id": p.category_id,
        "category_name": p.category.name_ar if p.category else None,
        "person_tag": p.person_tag,
        "occasion_tag": p.occasion_tag,
        "gift_type_tag": p.gift_type_tag,
        "budget_tag": p.budget_tag,
        "delivery_tag": p.delivery_tag,
        "is_latest": p.is_latest,
        "is_popular": p.is_popular,
        "status": p.status,
        "cover_image": p.cover_image,
        "sold": stats["sold"],
        "favorites": stats["favorites"],
        "score": stats["score"],
        "created_at": iso(p.created_at),
    }
    if full:
        images = [i.url for i in sorted(p.images, key=lambda i: (i.sort_order, i.id))]
        if p.cover_image and p.cover_image not in images:
            images.insert(0, p.cover_image)
        out.update(
            description_ar=p.description_ar,
            description_en=p.description_en,
            height_label=p.height_label,
            width_label=p.width_label,
            care_steps_ar=json_list(p.care_steps_ar),
            care_steps_en=json_list(p.care_steps_en),
            badges=json_list(p.badges_json),
            images=images,
        )
    return out


def _set_images(db: DbSession, product: Product, images: list[str]) -> None:
    urls = [u.strip() for u in images if u and u.strip()]
    urls = list(dict.fromkeys(urls))
    db.execute(delete(ProductImage).where(ProductImage.product_id == product.id))
    for i, url in enumerate(urls):
        db.add(ProductImage(product_id=product.id, url=url, sort_order=i))
    product.cover_image = urls[0] if urls else None


def _clean_steps(steps: list[str]) -> str:
    return json.dumps([s.strip() for s in steps if s and s.strip()], ensure_ascii=False)


def _validate_category(db: DbSession, category_id: int | None) -> None:
    if category_id is not None and db.get(Category, category_id) is None:
        raise AppError(400, "Category not found", code="INVALID_CATEGORY")


def _load_product(db: DbSession, product_id: int) -> Product:
    product = db.scalars(
        select(Product)
        .where(Product.id == product_id)
        .options(selectinload(Product.images), selectinload(Product.category))
    ).first()
    if product is None:
        raise AppError(404, "Product not found", code="NOT_FOUND")
    return product


@router.get("/products")
def list_products(
    db: DbSession,
    _admin: AdminUser,
    q: str | None = None,
    status: str | None = None,
    category_id: int | None = None,
    pinned: str | None = None,
    sort: str = "newest",
    page: int = 1,
    page_size: int = 20,
) -> dict:
    stmt = select(Product).options(selectinload(Product.category))
    if q:
        like = f"%{q.strip()}%"
        stmt = stmt.where(
            or_(Product.title_ar.ilike(like), Product.title_en.ilike(like), Product.sku.ilike(like))
        )
    if status:
        stmt = stmt.where(Product.status == status)
    if category_id:
        stmt = stmt.where(Product.category_id == category_id)
    if pinned == "latest":
        stmt = stmt.where(Product.is_latest.is_(True))
    elif pinned == "popular":
        stmt = stmt.where(Product.is_popular.is_(True))

    if sort == "popular":
        stmt, _sold, _favs, score = with_popularity(stmt)
        stmt = stmt.order_by(score.desc(), Product.id.desc())
    elif sort == "priceAsc":
        stmt = stmt.order_by(Product.price.asc(), Product.id.desc())
    elif sort == "priceDesc":
        stmt = stmt.order_by(Product.price.desc(), Product.id.desc())
    else:
        stmt = stmt.order_by(Product.created_at.desc(), Product.id.desc())

    rows, total = paginate(db, stmt, page, page_size)
    stats = product_stats(db, [p.id for p in rows])
    return page_out([_product_out(p, stats.get(p.id)) for p in rows], total, page, page_size)


@router.get("/products/{product_id}")
def get_product(product_id: int, db: DbSession, _admin: AdminUser) -> dict:
    product = _load_product(db, product_id)
    return _product_out(product, product_stats(db, [product.id]).get(product.id), full=True)


@router.post("/products")
def create_product(payload: ProductIn, db: DbSession, _admin: AdminUser) -> dict:
    ensure_unique(db, Product, "sku", payload.sku.strip())
    _validate_category(db, payload.category_id)
    data = payload.model_dump(exclude={"images", "care_steps_ar", "care_steps_en", "badges"})
    product = Product(**data)
    product.sku = payload.sku.strip()
    fill_english(product, "title", "description")
    product.care_steps_ar = _clean_steps(payload.care_steps_ar)
    product.care_steps_en = _clean_steps(payload.care_steps_en)
    product.badges_json = json.dumps([b.model_dump() for b in payload.badges], ensure_ascii=False)
    product.budget_tag = budget_for_price(product.price)
    db.add(product)
    db.flush()
    _set_images(db, product, payload.images)
    db.commit()
    bust_public_cache()
    return get_product(product.id, db, _admin)


@router.patch("/products/{product_id}")
def update_product(
    product_id: int, payload: ProductPatch, db: DbSession, _admin: AdminUser
) -> dict:
    product = _load_product(db, product_id)
    data = payload.model_dump(exclude_unset=True)
    if data.get("sku"):
        ensure_unique(db, Product, "sku", data["sku"].strip(), exclude_id=product.id)
        data["sku"] = data["sku"].strip()
    if "category_id" in data:
        _validate_category(db, data["category_id"])

    images = data.pop("images", None)
    for key in ("care_steps_ar", "care_steps_en"):
        if key in data:
            value = data.pop(key)
            if value is not None:
                setattr(product, key, _clean_steps(value))
    if "badges" in data:
        badges = data.pop("badges")
        if badges is not None:
            product.badges_json = json.dumps(badges, ensure_ascii=False)

    required = {
        "sku", "title_ar", "title_en", "description_ar", "description_en",
        "price", "rating", "is_latest", "is_popular", "status",
    }
    for key, value in data.items():
        if value is None and key in required:
            continue
        setattr(product, key, value)
    if images is not None:
        _set_images(db, product, images)
    product.budget_tag = budget_for_price(product.price)
    fill_english(product, "title", "description")
    db.commit()
    bust_public_cache()
    return get_product(product.id, db, _admin)


@router.delete("/products/{product_id}", response_model=OkOut)
def delete_product(product_id: int, db: DbSession, _admin: AdminUser) -> OkOut:
    product = get_or_404(db, Product, product_id, "Product")
    # Order history keeps its snapshot (title/image/price); carts & favorites drop it.
    db.execute(update(OrderItem).where(OrderItem.product_id == product.id).values(product_id=None))
    db.execute(delete(CartItem).where(CartItem.product_id == product.id))
    db.execute(delete(Favorite).where(Favorite.product_id == product.id))
    db.execute(delete(ProductImage).where(ProductImage.product_id == product.id))
    db.delete(product)
    db.commit()
    bust_public_cache()
    return OkOut()


# ——— Basket options: gift cards, wraps, addons ———

OPTION_MODELS = {
    "gift-cards": GiftCardOption,
    "wraps": WrapOption,
    "addons": AddonOption,
}


def _option_model(kind: str):
    model = OPTION_MODELS.get(kind)
    if model is None:
        raise AppError(404, "Unknown option type", code="NOT_FOUND")
    return model


def _option_out(o) -> dict:
    out = {
        "id": o.id,
        "code": o.code,
        "title_ar": o.title_ar,
        "title_en": o.title_en,
        "price": o.price,
        "image": o.image,
        "is_active": o.is_active,
    }
    if isinstance(o, AddonOption):
        out["category"] = o.category
    return out


@router.get("/options/{kind}")
def list_options(kind: str, db: DbSession, _admin: AdminUser) -> list[dict]:
    model = _option_model(kind)
    return [_option_out(o) for o in db.scalars(select(model).order_by(model.id)).all()]


@router.post("/options/{kind}")
def create_option(kind: str, payload: OptionIn, db: DbSession, _admin: AdminUser) -> dict:
    model = _option_model(kind)
    ensure_unique(db, model, "code", payload.code.strip())
    data = payload.model_dump(exclude={"category"})
    data["code"] = payload.code.strip()
    row = model(**data)
    fill_english(row, "title")
    if model is AddonOption:
        row.category = (payload.category or "all").strip() or "all"
    db.add(row)
    db.commit()
    return _option_out(row)


@router.patch("/options/{kind}/{option_id}")
def update_option(
    kind: str, option_id: int, payload: OptionPatch, db: DbSession, _admin: AdminUser
) -> dict:
    model = _option_model(kind)
    row = get_or_404(db, model, option_id, "Option")
    if payload.code:
        ensure_unique(db, model, "code", payload.code.strip(), exclude_id=row.id)
    data = payload.model_dump(exclude_unset=True)
    category = data.pop("category", None)
    for key, value in data.items():
        if value is not None:
            setattr(row, key, value.strip() if key == "code" else value)
    if model is AddonOption and category is not None:
        row.category = category.strip() or "all"
    fill_english(row, "title")
    db.commit()
    return _option_out(row)


@router.delete("/options/{kind}/{option_id}", response_model=OkOut)
def delete_option(kind: str, option_id: int, db: DbSession, _admin: AdminUser) -> OkOut:
    model = _option_model(kind)
    row = get_or_404(db, model, option_id, "Option")
    # Orders keep JSON snapshots; open carts just drop the choice.
    if model is GiftCardOption:
        db.execute(update(Cart).where(Cart.gift_card_id == row.id).values(gift_card_id=None))
    elif model is WrapOption:
        db.execute(update(Cart).where(Cart.wrap_id == row.id).values(wrap_id=None))
    db.delete(row)
    db.commit()
    return OkOut()
