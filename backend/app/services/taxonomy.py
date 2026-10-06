"""Single source of truth for filter values shared by the API and the Flutter app.

`label` values are translation keys in the app (or plain Arabic text, which the
app shows as-is when no translation key matches).
"""

from __future__ import annotations

GOVERNORATES = [
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
]

# Filters shown on the categories screen (order matters for the UI).
CATALOG_FILTERS = [
    {
        "id": "person",
        "title": "filter_person",
        "options": [
            {"id": "parents", "label": "أم / أب"},
            {"id": "sibling", "label": "أخ / أخت"},
            {"id": "spouse", "label": "زوج / زوجة"},
            {"id": "friends", "label": "أصدقاء"},
            {"id": "work", "label": "عمل"},
            {"id": "kids", "label": "opt_kids"},
            {"id": "grandparents", "label": "أجداد"},
            {"id": "other", "label": "شخص آخر"},
        ],
    },
    {
        "id": "occasion",
        "title": "filter_occasion",
        "options": [
            {"id": "birthday", "label": "opt_birthday"},
            {"id": "wedding", "label": "opt_wedding"},
            {"id": "graduation", "label": "opt_graduation"},
            {"id": "thanks", "label": "opt_thanks"},
            {"id": "newborn", "label": "opt_newborn"},
            {"id": "other_occ", "label": "أخرى"},
        ],
    },
    {
        "id": "gift_type",
        "title": "filter_gift_type",
        "options": [
            {"id": "flowers", "label": "opt_flowers"},
            {"id": "sweets", "label": "حلويات"},
            {"id": "perfume", "label": "opt_perfume"},
            {"id": "box", "label": "بوكسات"},
            {"id": "plants", "label": "opt_plants"},
            {"id": "custom", "label": "مخصص"},
        ],
    },
    {
        "id": "budget",
        "title": "filter_budget",
        "options": [
            {"id": "b1", "label": "opt_budget_low"},
            {"id": "b2", "label": "opt_budget_mid"},
            {"id": "b3", "label": "opt_budget_high"},
            {"id": "b4", "label": "opt_budget_vip"},
        ],
    },
    {
        "id": "price",
        "title": "filter_price",
        "options": [
            {"id": "asc", "label": "sort_price_asc"},
            {"id": "desc", "label": "sort_price_desc"},
        ],
    },
    {
        "id": "delivery",
        "title": "filter_delivery",
        "options": [
            {"id": "same_day", "label": "opt_delivery_today"},
            {"id": "tomorrow", "label": "opt_delivery_tomorrow"},
            {"id": "pickup", "label": "opt_pickup"},
        ],
    },
]

FAVORITE_CATEGORIES = [
    {"id": "all", "label": "common_all"},
    {"id": "bouquets", "label": "fav_cat_bouquets"},
    {"id": "cake", "label": "fav_cat_cake"},
    {"id": "chocolate", "label": "fav_cat_chocolate"},
    {"id": "cherry", "label": "fav_cat_cherry"},
    {"id": "lavender", "label": "fav_cat_lavender"},
]

ADDON_CATEGORIES = [
    {"id": "all", "label": "common_all"},
    {"id": "candles", "label": "شموع"},
    {"id": "chocolate", "label": "opt_chocolate"},
    {"id": "party", "label": "للأحتفال"},
    {"id": "balloons", "label": "بالونات"},
    {"id": "lavender", "label": "fav_cat_lavender"},
]

SPECIAL_GIFT_RECIPIENTS = [
    {"id": "parents", "label_key": "sg_opt_parents"},
    {"id": "sibling", "label_key": "sg_opt_sibling"},
    {"id": "spouse", "label_key": "sg_opt_spouse"},
    {"id": "friends", "label_key": "sg_opt_friends"},
    {"id": "kids", "label_key": "opt_kids"},
    {"id": "work", "label_key": "sg_opt_work"},
    {"id": "grandparents", "label_key": "sg_opt_grandparents"},
    {"id": "other", "label_key": "sg_opt_other_person"},
]

SPECIAL_GIFT_OCCASIONS = [
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
]

SPECIAL_GIFT_TYPES = [
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
]

# Group ids that cover several stored tags. A filter value not listed here
# matches only the identical tag.
GIFT_TYPE_GROUPS: dict[str, list[str]] = {
    "flowers": ["flowers", "bouquets", "cherry", "lavender"],
    "bouquets": ["flowers", "bouquets", "cherry", "lavender"],
    "sweets": ["sweets", "cake", "chocolate"],
}

OCCASION_GROUPS: dict[str, list[str]] = {
    # «أخرى» on the categories screen = any occasion not listed there.
    "other_occ": ["other_occ", "fathers", "mothers", "love", "formal", "work", "none"],
}

# Budget filter ids -> price range in IQD [min, max) — matches the app labels
# (opt_budget_low «أقل من 25 ألف», mid «25 – 50 ألف», high «50 – 100 ألف», vip «أكثر من 100 ألف»).
BUDGET_RANGES: dict[str, tuple[int, int | None]] = {
    "b1": (0, 25_000),
    "b2": (25_000, 50_000),
    "b3": (50_000, 100_000),
    "b4": (100_000, None),
}


def budget_for_price(price: int) -> str:
    for budget_id, (low, high) in BUDGET_RANGES.items():
        if price >= low and (high is None or price < high):
            return budget_id
    return "b4"


ORDER_STATUSES = ["pending", "confirmed", "shipping", "delivered", "cancelled"]


def gift_type_tags(value: str) -> list[str]:
    return GIFT_TYPE_GROUPS.get(value, [value])


def occasion_tags(value: str) -> list[str]:
    return OCCASION_GROUPS.get(value, [value])


def _ids(options: list[dict]) -> list[str]:
    return [o["id"] for o in options]


def _filter_ids(filter_id: str) -> list[str]:
    return next(_ids(f["options"]) for f in CATALOG_FILTERS if f["id"] == filter_id)


def lookups_payload(*, delivery_fee: int, free_delivery_threshold: int) -> dict:
    occasions = _filter_ids("occasion") + [
        o["id"] for o in SPECIAL_GIFT_OCCASIONS if o["id"] not in _filter_ids("occasion")
    ]
    gift_types = _filter_ids("gift_type") + [
        t
        for t in _ids(SPECIAL_GIFT_TYPES) + ["bouquets", "cherry", "lavender"]
        if t not in _filter_ids("gift_type")
    ]
    return {
        "governorates": GOVERNORATES,
        "person": _filter_ids("person"),
        "occasion": occasions,
        "gift_type": list(dict.fromkeys(gift_types)),
        "budget": _filter_ids("budget"),
        "delivery": _filter_ids("delivery"),
        "sort": ["newest", "priceAsc", "priceDesc", "popular"],
        "payment_methods": ["cod", "card"],
        "order_statuses": ORDER_STATUSES,
        "currency": "IQD",
        "free_delivery_threshold": free_delivery_threshold,
        "delivery_fee": delivery_fee,
        "filters": CATALOG_FILTERS,
        "favorite_categories": FAVORITE_CATEGORIES,
        "addon_categories": ADDON_CATEGORIES,
    }
