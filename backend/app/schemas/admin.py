"""Request bodies for the admin dashboard API (`/api/v1/admin`)."""

from __future__ import annotations

from pydantic import BaseModel, Field

SLUG = r"^[a-z0-9_\-]+$"


class AdminLoginIn(BaseModel):
    phone: str = Field(min_length=3, max_length=20)
    password: str = Field(min_length=1, max_length=128)


# ——— Catalog ———


class CategoryIn(BaseModel):
    slug: str = Field(min_length=1, max_length=64, pattern=SLUG)
    name_ar: str = Field(min_length=1, max_length=120)
    name_en: str = Field(default="", max_length=120)
    image: str | None = Field(default=None, max_length=512)
    sort_order: int = 0
    is_active: bool = True


class CategoryPatch(BaseModel):
    slug: str | None = Field(default=None, min_length=1, max_length=64, pattern=SLUG)
    name_ar: str | None = Field(default=None, min_length=1, max_length=120)
    name_en: str | None = Field(default=None, max_length=120)
    image: str | None = Field(default=None, max_length=512)
    sort_order: int | None = None
    is_active: bool | None = None


class BannerIn(BaseModel):
    title_ar: str = Field(default="", max_length=200)
    title_en: str = Field(default="", max_length=200)
    image: str = Field(min_length=1, max_length=512)
    link: str | None = Field(default=None, max_length=512)
    sort_order: int = 0
    is_active: bool = True


class BannerPatch(BaseModel):
    title_ar: str | None = Field(default=None, max_length=200)
    title_en: str | None = Field(default=None, max_length=200)
    image: str | None = Field(default=None, min_length=1, max_length=512)
    link: str | None = Field(default=None, max_length=512)
    sort_order: int | None = None
    is_active: bool | None = None


class BadgeIn(BaseModel):
    label: str = Field(min_length=1, max_length=120)
    icon: str = Field(default="truck", max_length=32)


class ProductIn(BaseModel):
    sku: str = Field(min_length=1, max_length=64)
    title_ar: str = Field(min_length=1, max_length=200)
    title_en: str = Field(default="", max_length=200)
    description_ar: str = ""
    description_en: str = ""
    price: int = Field(ge=0)
    rating: str = Field(default="4.5", max_length=8)
    category_id: int | None = None
    person_tag: str | None = Field(default=None, max_length=64)
    occasion_tag: str | None = Field(default=None, max_length=64)
    gift_type_tag: str | None = Field(default=None, max_length=64)
    budget_tag: str | None = Field(default=None, max_length=64)
    delivery_tag: str | None = Field(default=None, max_length=64)
    height_label: str | None = Field(default=None, max_length=32)
    width_label: str | None = Field(default=None, max_length=32)
    care_steps_ar: list[str] = []
    care_steps_en: list[str] = []
    badges: list[BadgeIn] = []
    is_latest: bool = False
    is_popular: bool = False
    status: str = Field(default="active", pattern="^(active|hidden)$")
    images: list[str] = Field(default_factory=list, max_length=12)


class ProductPatch(BaseModel):
    sku: str | None = Field(default=None, min_length=1, max_length=64)
    title_ar: str | None = Field(default=None, min_length=1, max_length=200)
    title_en: str | None = Field(default=None, max_length=200)
    description_ar: str | None = None
    description_en: str | None = None
    price: int | None = Field(default=None, ge=0)
    rating: str | None = Field(default=None, max_length=8)
    category_id: int | None = None
    person_tag: str | None = Field(default=None, max_length=64)
    occasion_tag: str | None = Field(default=None, max_length=64)
    gift_type_tag: str | None = Field(default=None, max_length=64)
    budget_tag: str | None = Field(default=None, max_length=64)
    delivery_tag: str | None = Field(default=None, max_length=64)
    height_label: str | None = Field(default=None, max_length=32)
    width_label: str | None = Field(default=None, max_length=32)
    care_steps_ar: list[str] | None = None
    care_steps_en: list[str] | None = None
    badges: list[BadgeIn] | None = None
    is_latest: bool | None = None
    is_popular: bool | None = None
    status: str | None = Field(default=None, pattern="^(active|hidden)$")
    images: list[str] | None = Field(default=None, max_length=12)


class OptionIn(BaseModel):
    code: str = Field(min_length=1, max_length=64)
    title_ar: str = Field(min_length=1, max_length=120)
    title_en: str = Field(default="", max_length=120)
    price: int = Field(ge=0)
    image: str = Field(min_length=1, max_length=512)
    category: str | None = Field(default=None, max_length=64)
    is_active: bool = True


class OptionPatch(BaseModel):
    code: str | None = Field(default=None, min_length=1, max_length=64)
    title_ar: str | None = Field(default=None, min_length=1, max_length=120)
    title_en: str | None = Field(default=None, max_length=120)
    price: int | None = Field(default=None, ge=0)
    image: str | None = Field(default=None, min_length=1, max_length=512)
    category: str | None = Field(default=None, max_length=64)
    is_active: bool | None = None


# ——— Sales ———


class UserPatch(BaseModel):
    name: str | None = Field(default=None, min_length=2, max_length=120)
    governorate: str | None = None
    is_active: bool | None = None
    is_admin: bool | None = None


class AdminCreateIn(BaseModel):
    phone: str = Field(min_length=10, max_length=20)
    password: str = Field(min_length=6, max_length=128)
    name: str = Field(min_length=2, max_length=120)


# ——— Content ———


class BroadcastIn(BaseModel):
    title_ar: str = Field(min_length=1, max_length=200)
    title_en: str = Field(default="", max_length=200)
    body_ar: str = Field(default="", max_length=2000)
    body_en: str = Field(default="", max_length=2000)
    link: str | None = Field(default=None, max_length=512)
    # Empty = everyone (who enabled notifications); otherwise one user by phone.
    phone: str | None = Field(default=None, max_length=20)


class FaqCategoryIn(BaseModel):
    slug: str = Field(min_length=1, max_length=64, pattern=SLUG)
    title_ar: str = Field(min_length=1, max_length=200)
    title_en: str = Field(default="", max_length=200)
    sort_order: int = 0


class FaqCategoryPatch(BaseModel):
    slug: str | None = Field(default=None, min_length=1, max_length=64, pattern=SLUG)
    title_ar: str | None = Field(default=None, min_length=1, max_length=200)
    title_en: str | None = Field(default=None, max_length=200)
    sort_order: int | None = None


class FaqItemIn(BaseModel):
    category_id: int
    question_ar: str = Field(min_length=1, max_length=500)
    question_en: str = Field(default="", max_length=500)
    answer_ar: str = Field(min_length=1)
    answer_en: str = ""
    sort_order: int = 0


class FaqItemPatch(BaseModel):
    category_id: int | None = None
    question_ar: str | None = Field(default=None, min_length=1, max_length=500)
    question_en: str | None = Field(default=None, max_length=500)
    answer_ar: str | None = Field(default=None, min_length=1)
    answer_en: str | None = None
    sort_order: int | None = None


class PrivacyIn(BaseModel):
    slug: str = Field(min_length=1, max_length=64, pattern=SLUG)
    title_ar: str = Field(min_length=1, max_length=200)
    title_en: str = Field(default="", max_length=200)
    body_ar: str = Field(min_length=1)
    body_en: str = ""
    sort_order: int = 0


class PrivacyPatch(BaseModel):
    slug: str | None = Field(default=None, min_length=1, max_length=64, pattern=SLUG)
    title_ar: str | None = Field(default=None, min_length=1, max_length=200)
    title_en: str | None = Field(default=None, max_length=200)
    body_ar: str | None = Field(default=None, min_length=1)
    body_en: str | None = None
    sort_order: int | None = None


class TicketPatch(BaseModel):
    status: str | None = Field(default=None, pattern="^(open|in_progress|closed)$")
    # Optional reply: sent to the customer as an in-app notification.
    reply: str | None = Field(default=None, max_length=2000)


class SettingsIn(BaseModel):
    values: dict[str, str]
