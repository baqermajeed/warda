from __future__ import annotations

from fastapi import APIRouter

from app.deps import OptionalUser
from app.models import Favorite, Product
from app.schemas import Page, SpecialGiftRecommendIn
from app.services.serializers import product_card

router = APIRouter(prefix="/special-gift", tags=["special-gift"])


@router.get("/options")
def options() -> dict:
    return {
        "recipients": [
            {"id": "parents", "label_key": "sg_opt_parents"},
            {"id": "sibling", "label_key": "sg_opt_sibling"},
            {"id": "spouse", "label_key": "sg_opt_spouse"},
            {"id": "friends", "label_key": "sg_opt_friends"},
            {"id": "kids", "label_key": "opt_kids"},
            {"id": "work", "label_key": "sg_opt_work"},
            {"id": "grandparents", "label_key": "sg_opt_grandparents"},
            {"id": "other", "label_key": "sg_opt_other_person"},
        ],
        "occasions": [
            {"id": "birthday", "label_key": "opt_birthday"},
            {"id": "fathers", "label_key": "sg_opt_fathers"},
            {"id": "wedding", "label_key": "sg_opt_wedding_engagement"},
            {"id": "newborn", "label_key": "opt_newborn"},
            {"id": "love", "label_key": "sg_opt_valentines"},
            {"id": "mothers", "label_key": "sg_opt_mothers"},
            {"id": "thanks", "label_key": "opt_thanks"},
            {"id": "work", "label_key": "sg_opt_work_congrats"},
            {"id": "graduation", "label_key": "sg_opt_grad_success"},
            {"id": "formal", "label_key": "sg_opt_formal"},
            {"id": "none", "label_key": "sg_opt_no_occasion"},
        ],
        "types": [
            {"id": "flowers", "label_key": "sg_opt_flower_bouquets"},
            {"id": "cake", "label_key": "opt_cake"},
            {"id": "chocolate", "label_key": "opt_chocolate"},
            {"id": "plants", "label_key": "opt_plants"},
            {"id": "jewelry", "label_key": "sg_opt_jewelry"},
            {"id": "candles", "label_key": "sg_opt_candles"},
            {"id": "home", "label_key": "sg_opt_home"},
            {"id": "men", "label_key": "sg_opt_gifts_men"},
            {"id": "women", "label_key": "sg_opt_gifts_women"},
            {"id": "care", "label_key": "sg_opt_care"},
            {"id": "toys", "label_key": "opt_toys"},
        ],
    }


@router.post("/recommend", response_model=Page)
async def recommend(
    payload: SpecialGiftRecommendIn,
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
        filters.append(Product.occasion_tag == payload.occasion_id)
    if payload.type_id:
        filters.append(Product.gift_type_tag == payload.type_id)
    if payload.budget_from is not None:
        filters.append(Product.price >= payload.budget_from)
    if payload.budget_to is not None:
        filters.append(Product.price <= payload.budget_to)

    rows = await Product.find(*filters).sort("-is_popular", "-id").to_list()
    if not rows:
        soft = [Product.status == "active"]
        if payload.type_id:
            soft.append(Product.gift_type_tag == payload.type_id)
        rows = await Product.find(*soft).sort("-is_popular", "-id").limit(40).to_list()

    favs: set[int] = set()
    if user:
        fav_rows = await Favorite.find(Favorite.user_id == user.id).to_list()
        favs = {r.product_id for r in fav_rows}
    total = len(rows)
    chunk = rows[(page - 1) * page_size : (page - 1) * page_size + page_size]
    return Page(
        items=[product_card(p, favorite_ids=favs).model_dump() for p in chunk],
        total=total,
        page=page,
        page_size=page_size,
    )
