"""Editable app settings (stored in `app_settings`, managed from the admin dashboard)."""

from __future__ import annotations

from sqlalchemy.orm import Session

from app.config import settings
from app.models import AppSetting

# key -> default value. Only these keys are editable from the dashboard.
SETTING_DEFAULTS: dict[str, str] = {
    "support.phone": "+9647700000000",
    "support.whatsapp": "+9647700000000",
    "support.email": "support@warda.app",
    "support.hours_ar": "يومياً 9 ص – 9 م",
    "support.hours_en": "Daily 9 AM – 9 PM",
    "share.url": "https://warda.app/download",
    "share.message_ar": "جرب تطبيق وردة للهدايا والزهور!",
    "share.message_en": "Try Warda — gifts and flowers delivered!",
    "share.product_url": "https://warda.app/p",
    "pricing.delivery_fee": str(settings.delivery_fee),
    "pricing.free_delivery_threshold": str(settings.free_delivery_threshold),
}

INT_SETTINGS = {"pricing.delivery_fee", "pricing.free_delivery_threshold"}


def get_setting(db: Session, key: str) -> str:
    row = db.get(AppSetting, key)
    if row is not None:
        return row.value
    return SETTING_DEFAULTS.get(key, "")


def get_int_setting(db: Session, key: str) -> int:
    try:
        return int(get_setting(db, key))
    except ValueError:
        return int(SETTING_DEFAULTS[key])


def all_settings(db: Session) -> dict[str, str]:
    return {key: get_setting(db, key) for key in SETTING_DEFAULTS}


def delivery_config(db: Session) -> tuple[int, int]:
    """(delivery_fee, free_delivery_threshold)"""
    return (
        get_int_setting(db, "pricing.delivery_fee"),
        get_int_setting(db, "pricing.free_delivery_threshold"),
    )
