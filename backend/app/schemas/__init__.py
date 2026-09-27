from __future__ import annotations

from pydantic import BaseModel, Field


class Page(BaseModel):
    items: list
    total: int
    page: int
    page_size: int


class OkOut(BaseModel):
    ok: bool = True


class UserOut(BaseModel):
    id: int
    phone: str
    name: str
    email: str | None = None
    governorate: str | None = None
    notifications_enabled: bool = True
    locale: str = "ar"

    model_config = {"from_attributes": True}


class TokenOut(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int
    user: UserOut | None = None


class LoginIn(BaseModel):
    phone: str = Field(min_length=10, max_length=20)
    password: str = Field(min_length=6, max_length=128)


class RegisterIn(BaseModel):
    phone: str
    password: str = Field(min_length=6, max_length=128)
    name: str = Field(min_length=2, max_length=120)
    governorate: str = Field(min_length=2, max_length=64)


class RefreshIn(BaseModel):
    refresh_token: str


class LogoutIn(BaseModel):
    refresh_token: str | None = None


class ProfileUpdateIn(BaseModel):
    name: str | None = Field(default=None, min_length=2, max_length=120)
    governorate: str | None = None
    notifications_enabled: bool | None = None
    locale: str | None = Field(default=None, max_length=8)
    email: str | None = None


class ProductCardOut(BaseModel):
    id: int
    title: str
    title_ar: str
    title_en: str
    price: int
    price_label: str
    rating: str
    image: str | None
    is_favorite: bool = False
    person_tag: str | None = None
    occasion_tag: str | None = None
    gift_type_tag: str | None = None


class CategoryOut(BaseModel):
    id: int
    slug: str
    name_ar: str
    name_en: str
    image: str | None = None

    model_config = {"from_attributes": True}


class BannerOut(BaseModel):
    id: int
    title_ar: str
    title_en: str
    image: str
    link: str | None = None

    model_config = {"from_attributes": True}

class HomeOut(BaseModel):
    banners: list[BannerOut]
    categories: list[CategoryOut]
    latest: list[ProductCardOut]
    popular: list[ProductCardOut]
    all_gifts: list[ProductCardOut]


class ProductDetailOut(ProductCardOut):
    description_ar: str
    description_en: str
    images: list[str]
    height_label: str | None = None
    width_label: str | None = None
    care_steps_ar: list[str] = []
    care_steps_en: list[str] = []
    badges: list[dict] = []
    similar: list[ProductCardOut] = []


class CartItemIn(BaseModel):
    product_id: int
    qty: int = Field(default=1, ge=1, le=99)


class CartItemUpdateIn(BaseModel):
    qty: int = Field(ge=0, le=99)


class CartOptionsIn(BaseModel):
    gift_card_id: int | None = None
    wrap_id: int | None = None
    gift_from: str = Field(default="", max_length=120)
    gift_to: str = Field(default="", max_length=120)
    gift_message: str = Field(default="", max_length=150)
    addon_ids: list[int] = Field(default_factory=list)


class OptionOut(BaseModel):
    id: int
    code: str
    title_ar: str
    title_en: str
    price: int
    image: str
    category: str | None = None


class CartItemOut(BaseModel):
    id: int
    product_id: int
    title_ar: str
    title_en: str
    image: str | None
    unit_price: int
    qty: int
    line_total: int


class CartOut(BaseModel):
    items: list[CartItemOut]
    gift_card: OptionOut | None = None
    wrap: OptionOut | None = None
    addons: list[OptionOut] = []
    gift_from: str = ""
    gift_to: str = ""
    gift_message: str = ""
    pricing: dict


class OrderCreateIn(BaseModel):
    recipient_name: str = Field(min_length=2, max_length=120)
    recipient_phone: str
    governorate: str | None = None
    landmark: str = ""
    unknown_address: bool = False
    payment_method: str = Field(default="cod", pattern="^(cod|card)$")


class OrderItemOut(BaseModel):
    title_ar: str
    title_en: str
    image: str | None
    unit_price: int
    qty: int
    line_total: int


class OrderOut(BaseModel):
    id: int
    code: str
    status: str
    payment_method: str
    recipient_name: str
    recipient_phone: str
    governorate: str | None
    landmark: str
    unknown_address: bool
    items: list[OrderItemOut]
    gift_card: dict | None = None
    wrap: dict | None = None
    addons: list[dict] = []
    gift_from: str = ""
    gift_to: str = ""
    gift_message: str = ""
    subtotal: int
    wrap_price: int
    addons_price: int
    card_price: int
    delivery_price: int
    total: int
    created_at: str


class ReminderIn(BaseModel):
    person_name: str = Field(min_length=1, max_length=120)
    type_id: str
    date: str  # ISO date
    notify_enabled: bool = True
    remind_days_before: int = Field(default=3, ge=0, le=30)
    note: str = Field(default="", max_length=500)


class ReminderOut(BaseModel):
    id: int
    person_name: str
    type_id: str
    date: str
    notify_enabled: bool
    remind_days_before: int
    note: str


class SpecialGiftRecommendIn(BaseModel):
    recipient_id: str | None = None
    occasion_id: str | None = None
    type_id: str | None = None
    budget_from: int | None = None
    budget_to: int | None = None


class SupportTicketIn(BaseModel):
    subject: str = Field(min_length=2, max_length=200)
    message: str = Field(min_length=2, max_length=4000)
    name: str = Field(default="", max_length=120)
    phone: str = Field(default="", max_length=20)
