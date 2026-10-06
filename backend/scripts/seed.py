"""Seed demo catalog and CMS content for Warda."""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from sqlalchemy import func, select

from app.db import Base, SessionLocal, engine  # noqa: E402
from app.models import (  # noqa: E402
    AddonOption,
    AppSetting,
    Banner,
    Category,
    FaqCategory,
    FaqItem,
    GiftCardOption,
    PrivacySection,
    Product,
    ProductImage,
    WrapOption,
)


def seed() -> None:
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        if (db.scalar(select(func.count()).select_from(Product)) or 0) > 0:
            print("Base seed skipped: products already exist")
            seed_extras(db)
            return

        cats = [
            Category(slug="person", name_ar="لشخص", name_en="For someone", sort_order=1),
            Category(slug="occasion", name_ar="لمناسبة", name_en="Occasion", sort_order=2),
            Category(slug="gift_type", name_ar="نوع الهدية", name_en="Gift type", sort_order=3),
            Category(slug="flowers", name_ar="باقات ورد", name_en="Bouquets", sort_order=4),
        ]
        db.add_all(cats)
        db.flush()

        flowers = cats[3]
        products_data = [
            ("SKU-001", "باقة زهور الأوركيد الخلابة", "Stunning orchid bouquet", 10000, True, True, "spouse", "birthday", "flowers", "b1"),
            ("SKU-002", "باقة التوليب والأقحوان", "Tulip & daisy bouquet", 126000, True, True, "spouse", "love", "flowers", "b3"),
            ("SKU-003", "باقة ورد أحمر كلاسيكية", "Classic red roses", 85000, False, True, "spouse", "wedding", "flowers", "b2"),
            ("SKU-004", "صندوق شوكولاه فاخر", "Luxury chocolate box", 45000, True, False, "friends", "thanks", "chocolate", "b2"),
            ("SKU-005", "كيكة احتفال", "Celebration cake", 55000, False, True, "kids", "birthday", "cake", "b2"),
            ("SKU-006", "نبتة داخلية أنيقة", "Elegant indoor plant", 30000, True, False, "work", "formal", "plants", "b1"),
            ("SKU-007", "شموع معطرة", "Scented candles", 22000, False, False, "friends", "thanks", "candles", "b1"),
            ("SKU-008", "باقة لافندر", "Lavender bouquet", 40000, True, True, "parents", "mothers", "flowers", "b2"),
        ]

        care = json.dumps(
            [
                "ضع الباقة في ماء نظيف وعذب، مع تغيير الماء كل يومين.",
                "قص أطراف السيقان بزاوية مائلة لتحسين امتصاص الماء",
                "ابعد الباقة عن أشعة الشمس المباشرة والحرارة العالية",
            ],
            ensure_ascii=False,
        )
        care_en = json.dumps(
            [
                "Place in clean water and change every two days.",
                "Trim stems at an angle.",
                "Keep away from direct sun and heat.",
            ],
            ensure_ascii=False,
        )
        badges = json.dumps(
            [
                {"label": "product_badge_natural", "icon": "truck"},
                {"label": "product_badge_free_delivery", "icon": "map"},
            ]
        )

        for i, (sku, ar, en, price, latest, popular, person, occasion, gtype, budget) in enumerate(
            products_data, start=1
        ):
            p = Product(
                sku=sku,
                title_ar=ar,
                title_en=en,
                description_ar="باقة رائعة تناسب كل المناسبات الخاصة وتعبّر عن المشاعر الدافئة.",
                description_en="A beautiful gift suitable for special occasions.",
                price=price,
                rating="4.5",
                category_id=flowers.id,
                person_tag=person,
                occasion_tag=occasion,
                gift_type_tag=gtype,
                budget_tag=budget,
                delivery_tag="same_day",
                height_label="10.5cm",
                width_label="17.5cm",
                care_steps_ar=care,
                care_steps_en=care_en,
                badges_json=badges,
                # «أحدث/الأكثر شهرة» تُحسب تلقائيًا؛ هذه الحقول للتثبيت اليدوي من لوحة التحكم.
                is_latest=False,
                is_popular=False,
                status="active",
                cover_image=f"/api/v1/media/product_{i}.jpg",
            )
            db.add(p)
            db.flush()
            db.add(ProductImage(product_id=p.id, url=p.cover_image, sort_order=0))

        db.add_all(
            [
                Banner(
                    title_ar="هدايا مميزة",
                    title_en="Special gifts",
                    image="/api/v1/media/banner_1.jpg",
                    sort_order=1,
                ),
                Banner(
                    title_ar="توصيل سريع",
                    title_en="Fast delivery",
                    image="/api/v1/media/banner_2.jpg",
                    sort_order=2,
                ),
            ]
        )

        db.add_all(
            [
                GiftCardOption(
                    code="card_wedding",
                    title_ar="مبارك الزواج",
                    title_en="Happy Wedding",
                    price=2000,
                    image="/api/v1/media/card_1.jpg",
                ),
                GiftCardOption(
                    code="card_grad",
                    title_ar="مبارك التخرج",
                    title_en="Happy Graduation",
                    price=2000,
                    image="/api/v1/media/card_2.jpg",
                ),
                GiftCardOption(
                    code="card_bday",
                    title_ar="ميلاد سعيد",
                    title_en="Happy Birthday",
                    price=2000,
                    image="/api/v1/media/card_3.jpg",
                ),
            ]
        )
        db.add_all(
            [
                WrapOption(
                    code=f"wrap_{i}",
                    title_ar="ورق كلاسيكي فاخر",
                    title_en="Luxury classic wrap",
                    price=10000,
                    image=f"/api/v1/media/wrap_{i}.jpg",
                )
                for i in range(1, 5)
            ]
        )
        db.add_all(
            [
                AddonOption(
                    code="a1",
                    title_ar="شوكولاه فاخرة",
                    title_en="Luxury chocolate",
                    price=10000,
                    image="/api/v1/media/addon_1.jpg",
                    category="chocolate",
                ),
                AddonOption(
                    code="a2",
                    title_ar="بالونات احتفال",
                    title_en="Party balloons",
                    price=10000,
                    image="/api/v1/media/addon_2.jpg",
                    category="balloons",
                ),
                AddonOption(
                    code="a3",
                    title_ar="شموع معطرة",
                    title_en="Scented candles",
                    price=10000,
                    image="/api/v1/media/addon_3.jpg",
                    category="candles",
                ),
                AddonOption(
                    code="a4",
                    title_ar="صندوق احتفال",
                    title_en="Party box",
                    price=10000,
                    image="/api/v1/media/addon_4.jpg",
                    category="party",
                ),
            ]
        )

        faq = FaqCategory(slug="orders", title_ar="الطلبات", title_en="Orders", sort_order=1)
        db.add(faq)
        db.flush()
        db.add(
            FaqItem(
                category_id=faq.id,
                question_ar="كم يستغرق التوصيل؟",
                question_en="How long does delivery take?",
                answer_ar="عادةً في نفس اليوم داخل المدن الرئيسية.",
                answer_en="Usually same-day in major cities.",
                sort_order=1,
            )
        )
        db.add(
            PrivacySection(
                slug="intro",
                title_ar="مقدمة",
                title_en="Introduction",
                body_ar="نحترم خصوصيتك ونحمي بياناتك.",
                body_en="We respect your privacy and protect your data.",
                sort_order=1,
            )
        )
        db.add_all(
            [
                AppSetting(key="share.url", value="https://warda.app/download"),
                AppSetting(key="share.message_ar", value="جرب تطبيق وردة للهدايا والزهور!"),
                AppSetting(key="share.message_en", value="Try Warda — gifts and flowers!"),
                AppSetting(key="support.phone", value="+9647700000000"),
                AppSetting(key="support.whatsapp", value="+9647700000000"),
                AppSetting(key="support.email", value="support@warda.app"),
            ]
        )

        db.commit()
        seed_extras(db)
        print("Seed completed successfully")
    finally:
        db.close()


EXTRA_PRODUCTS = [
    # sku, title_ar, title_en, price, person, occasion, gift_type, budget, delivery
    ("SKU-101", "علبة حلويات شرقية", "Oriental sweets box", 35000, "parents", "thanks", "sweets", "b1", "tomorrow"),
    ("SKU-102", "عطر فاخر", "Luxury perfume", 150000, "spouse", "love", "perfume", "b4", "same_day"),
    ("SKU-103", "بوكس هدايا مشكّل", "Mixed gift box", 65000, "friends", "birthday", "box", "b2", "pickup"),
    ("SKU-104", "هدية مخصصة بالاسم", "Personalised name gift", 50000, "sibling", "graduation", "custom", "b2", "tomorrow"),
    ("SKU-105", "باقة زهر الكرز", "Cherry blossom bouquet", 70000, "spouse", "wedding", "cherry", "b2", "same_day"),
    ("SKU-106", "باقة لافندر صغيرة", "Small lavender bouquet", 25000, "friends", "thanks", "lavender", "b1", "pickup"),
    ("SKU-107", "سوار فضة", "Silver bracelet", 180000, "spouse", "love", "jewelry", "b4", "tomorrow"),
    ("SKU-108", "ديكور منزلي", "Home décor piece", 45000, "parents", "formal", "home", "b2", "tomorrow"),
    ("SKU-109", "طقم هدايا رجالي", "Men's gift set", 90000, "parents", "fathers", "men", "b3", "same_day"),
    ("SKU-110", "طقم هدايا نسائي", "Women's gift set", 90000, "parents", "mothers", "women", "b3", "same_day"),
    ("SKU-111", "سلة عناية شخصية", "Self-care basket", 60000, "grandparents", "none", "care", "b2", "pickup"),
    ("SKU-112", "لعبة أطفال", "Kids toy", 30000, "kids", "newborn", "toys", "b1", "same_day"),
    ("SKU-113", "هدية لزميل العمل", "Gift for a colleague", 40000, "work", "work", "box", "b1", "tomorrow"),
    ("SKU-114", "هدية لشخص مميز", "Gift for someone special", 55000, "other", "other_occ", "custom", "b2", "pickup"),
]

EXTRA_ADDONS = [
    ("a5", "غصن لافندر", "Lavender sprig", 5000, "/api/v1/media/addon_5.jpg", "lavender"),
]

BANNER_LINKS = {
    "Special gifts": "/special-gift",
    "Fast delivery": "/search?delivery=same_day",
}


def seed_extras(db) -> None:
    """Idempotent: adds rows that are missing, so it is safe on an existing database."""
    existing_skus = set(db.scalars(select(Product.sku)).all())
    category = db.scalars(select(Category).where(Category.slug == "flowers")).first()
    added = 0
    for i, (sku, ar, en, price, person, occasion, gtype, budget, delivery) in enumerate(
        EXTRA_PRODUCTS, start=1
    ):
        if sku in existing_skus:
            continue
        image = f"/api/v1/media/product_{(i % 8) + 1}.jpg"
        p = Product(
            sku=sku,
            title_ar=ar,
            title_en=en,
            description_ar="هدية مميزة مختارة بعناية لتناسب مناسبتك.",
            description_en="A carefully selected gift for your occasion.",
            price=price,
            rating="4.6",
            category_id=category.id if category else None,
            person_tag=person,
            occasion_tag=occasion,
            gift_type_tag=gtype,
            budget_tag=budget,
            delivery_tag=delivery,
            is_latest=False,
            is_popular=False,
            status="active",
            cover_image=image,
        )
        db.add(p)
        db.flush()
        db.add(ProductImage(product_id=p.id, url=image, sort_order=0))
        added += 1

    existing_codes = set(db.scalars(select(AddonOption.code)).all())
    for code, ar, en, price, image, cat in EXTRA_ADDONS:
        if code not in existing_codes:
            db.add(
                AddonOption(
                    code=code, title_ar=ar, title_en=en, price=price, image=image, category=cat
                )
            )

    for banner in db.scalars(select(Banner)).all():
        if not banner.link and banner.title_en in BANNER_LINKS:
            banner.link = BANNER_LINKS[banner.title_en]

    if db.get(AppSetting, "share.product_url") is None:
        db.add(AppSetting(key="share.product_url", value="https://warda.app/p"))

    db.commit()
    print(f"Extras seeded: {added} products added")


if __name__ == "__main__":
    seed()
