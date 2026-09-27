from __future__ import annotations

import re

IRAQI_PHONE_RE = re.compile(r"^07[3-9]\d{8}$")


def normalize_iraqi_phone(phone: str) -> str:
    cleaned = re.sub(r"\s+", "", phone.strip())
    if cleaned.startswith("+964"):
        cleaned = "0" + cleaned[4:]
    elif cleaned.startswith("964"):
        cleaned = "0" + cleaned[3:]
    return cleaned


def is_valid_iraqi_phone(phone: str) -> bool:
    return bool(IRAQI_PHONE_RE.match(normalize_iraqi_phone(phone)))


def require_iraqi_phone(phone: str) -> str:
    from app.errors import AppError

    normalized = normalize_iraqi_phone(phone)
    if not IRAQI_PHONE_RE.match(normalized):
        raise AppError(400, "Invalid Iraqi phone number", code="INVALID_PHONE")
    return normalized
