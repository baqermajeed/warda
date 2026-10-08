from __future__ import annotations

from datetime import datetime

from beanie import Document, Insert, before_event
from pydantic import BaseModel, Field

from app.config import utcnow
from app.db import next_seq


class ProductImageEmbed(BaseModel):
    id: int
    url: str
    sort_order: int = 0


class CartItemEmbed(BaseModel):
    id: int
    product_id: int
    qty: int = 1
    unit_price: int


class OrderItemEmbed(BaseModel):
    id: int
    product_id: int | None = None
    title_ar: str
    title_en: str
    image: str | None = None
    unit_price: int
    qty: int
    line_total: int


class FaqItemEmbed(BaseModel):
    id: int
    question_ar: str
    question_en: str
    answer_ar: str
    answer_en: str
    sort_order: int = 0


class TimestampMixin(BaseModel):
    created_at: datetime = Field(default_factory=utcnow)
    updated_at: datetime = Field(default_factory=utcnow)


async def _assign_doc_id(doc: Document) -> None:
    if getattr(doc, "id", None) is None:
        name = doc.get_settings().name
        doc.id = await next_seq(name)


class User(Document, TimestampMixin):
    id: int | None = None
    phone: str
    password_hash: str = ""
    name: str = ""
    email: str | None = None
    governorate: str | None = None
    is_active: bool = True
    is_admin: bool = False
    notifications_enabled: bool = True
    locale: str = "ar"

    class Settings:
        name = "users"

    @before_event(Insert)
    async def _on_insert(self) -> None:
        await _assign_doc_id(self)


class RefreshToken(Document):
    id: int | None = None
    user_id: int
    token_hash: str
    expires_at: datetime
    revoked_at: datetime | None = None
    created_at: datetime = Field(default_factory=utcnow)

    class Settings:
        name = "refresh_tokens"

    @before_event(Insert)
    async def _on_insert(self) -> None:
        await _assign_doc_id(self)


class Category(Document, TimestampMixin):
    id: int | None = None
    slug: str
    name_ar: str
    name_en: str
    image: str | None = None
    parent_id: int | None = None
    sort_order: int = 0
    is_active: bool = True

    class Settings:
        name = "categories"

    @before_event(Insert)
    async def _on_insert(self) -> None:
        await _assign_doc_id(self)


class Product(Document, TimestampMixin):
    id: int | None = None
    sku: str
    title_ar: str
    title_en: str
    description_ar: str = ""
    description_en: str = ""
    price: int
    rating: str = "4.5"
    category_id: int | None = None
    person_tag: str | None = None
    occasion_tag: str | None = None
    gift_type_tag: str | None = None
    budget_tag: str | None = None
    delivery_tag: str | None = None
    height_label: str | None = None
    width_label: str | None = None
    care_steps_ar: str = ""
    care_steps_en: str = ""
    badges_json: str = "[]"
    is_latest: bool = False
    is_popular: bool = False
    status: str = "active"
    cover_image: str | None = None
    images: list[ProductImageEmbed] = Field(default_factory=list)

    class Settings:
        name = "products"

    @before_event(Insert)
    async def _on_insert(self) -> None:
        await _assign_doc_id(self)


class Banner(Document, TimestampMixin):
    id: int | None = None
    title_ar: str = ""
    title_en: str = ""
    image: str
    link: str | None = None
    sort_order: int = 0
    is_active: bool = True

    class Settings:
        name = "banners"

    @before_event(Insert)
    async def _on_insert(self) -> None:
        await _assign_doc_id(self)


class Favorite(Document):
    id: int | None = None
    user_id: int
    product_id: int
    created_at: datetime = Field(default_factory=utcnow)

    class Settings:
        name = "favorites"

    @before_event(Insert)
    async def _on_insert(self) -> None:
        await _assign_doc_id(self)


class GiftCardOption(Document, TimestampMixin):
    id: int | None = None
    code: str
    title_ar: str
    title_en: str
    price: int
    image: str
    is_active: bool = True

    class Settings:
        name = "gift_card_options"

    @before_event(Insert)
    async def _on_insert(self) -> None:
        await _assign_doc_id(self)


class WrapOption(Document, TimestampMixin):
    id: int | None = None
    code: str
    title_ar: str
    title_en: str
    price: int
    image: str
    is_active: bool = True

    class Settings:
        name = "wrap_options"

    @before_event(Insert)
    async def _on_insert(self) -> None:
        await _assign_doc_id(self)


class AddonOption(Document, TimestampMixin):
    id: int | None = None
    code: str
    title_ar: str
    title_en: str
    price: int
    image: str
    category: str = "all"
    is_active: bool = True

    class Settings:
        name = "addon_options"

    @before_event(Insert)
    async def _on_insert(self) -> None:
        await _assign_doc_id(self)


class Cart(Document, TimestampMixin):
    id: int | None = None
    user_id: int
    gift_card_id: int | None = None
    wrap_id: int | None = None
    gift_from: str = ""
    gift_to: str = ""
    gift_message: str = ""
    addon_ids_json: str = "[]"
    items: list[CartItemEmbed] = Field(default_factory=list)

    class Settings:
        name = "carts"

    @before_event(Insert)
    async def _on_insert(self) -> None:
        await _assign_doc_id(self)


class Order(Document, TimestampMixin):
    id: int | None = None
    code: str
    user_id: int
    status: str = "pending"
    payment_method: str = "cod"
    recipient_name: str
    recipient_phone: str
    governorate: str | None = None
    landmark: str = ""
    unknown_address: bool = False
    subtotal: int
    wrap_price: int = 0
    addons_price: int = 0
    card_price: int = 0
    delivery_price: int = 0
    total: int
    gift_from: str = ""
    gift_to: str = ""
    gift_message: str = ""
    gift_card_snapshot: str = "{}"
    wrap_snapshot: str = "{}"
    addons_snapshot: str = "[]"
    items: list[OrderItemEmbed] = Field(default_factory=list)

    class Settings:
        name = "orders"

    @before_event(Insert)
    async def _on_insert(self) -> None:
        await _assign_doc_id(self)


class Reminder(Document, TimestampMixin):
    id: int | None = None
    user_id: int
    person_name: str
    type_id: str
    date: datetime
    notify_enabled: bool = True
    remind_days_before: int = 3
    note: str = ""

    class Settings:
        name = "reminders"

    @before_event(Insert)
    async def _on_insert(self) -> None:
        await _assign_doc_id(self)


class FaqCategory(Document, TimestampMixin):
    id: int | None = None
    slug: str
    title_ar: str
    title_en: str
    sort_order: int = 0
    items: list[FaqItemEmbed] = Field(default_factory=list)

    class Settings:
        name = "faq_categories"

    @before_event(Insert)
    async def _on_insert(self) -> None:
        await _assign_doc_id(self)


class PrivacySection(Document, TimestampMixin):
    id: int | None = None
    slug: str
    title_ar: str
    title_en: str
    body_ar: str
    body_en: str
    sort_order: int = 0

    class Settings:
        name = "privacy_sections"

    @before_event(Insert)
    async def _on_insert(self) -> None:
        await _assign_doc_id(self)


class SupportTicket(Document, TimestampMixin):
    id: int | None = None
    user_id: int | None = None
    name: str = ""
    phone: str = ""
    subject: str
    message: str
    status: str = "open"

    class Settings:
        name = "support_tickets"

    @before_event(Insert)
    async def _on_insert(self) -> None:
        await _assign_doc_id(self)


class AppSetting(Document):
    key: str
    value: str

    class Settings:
        name = "app_settings"


class Notification(Document):
    id: int | None = None
    user_id: int
    type: str = "general"
    title_ar: str
    title_en: str
    body_ar: str = ""
    body_en: str = ""
    link: str | None = None
    dedupe_key: str | None = None
    read_at: datetime | None = None
    created_at: datetime = Field(default_factory=utcnow)

    class Settings:
        name = "notifications"

    @before_event(Insert)
    async def _on_insert(self) -> None:
        await _assign_doc_id(self)


ALL_DOCUMENT_MODELS = [
    User,
    RefreshToken,
    Category,
    Product,
    Banner,
    Favorite,
    GiftCardOption,
    WrapOption,
    AddonOption,
    Cart,
    Order,
    Reminder,
    FaqCategory,
    PrivacySection,
    SupportTicket,
    AppSetting,
    Notification,
]
