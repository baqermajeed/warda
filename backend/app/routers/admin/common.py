"""Shared helpers for the admin routers."""

from __future__ import annotations

import json
from typing import Any

from pydantic import BaseModel
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.cache import cache_delete
from app.errors import AppError

PUBLIC_CACHE_KEYS = ("home:v1", "lookups:v2")


def bust_public_cache() -> None:
    """Admin writes must show up in the app immediately."""
    for key in PUBLIC_CACHE_KEYS:
        cache_delete(key)


def page_params(page: int, page_size: int) -> tuple[int, int]:
    return max(1, page), min(max(1, page_size), 200)


def paginate(db: Session, stmt, page: int, page_size: int) -> tuple[list, int]:
    page, page_size = page_params(page, page_size)
    total = db.scalar(select(func.count()).select_from(stmt.order_by(None).subquery())) or 0
    rows = db.scalars(stmt.offset((page - 1) * page_size).limit(page_size)).all()
    return list(rows), total


def page_out(items: list[Any], total: int, page: int, page_size: int) -> dict:
    page, page_size = page_params(page, page_size)
    return {"items": items, "total": total, "page": page, "page_size": page_size}


def apply_patch(obj: Any, patch: BaseModel, *, required: set[str] = frozenset()) -> dict:
    """Copies explicitly-sent fields onto `obj`. `null` is ignored for required columns."""
    data = patch.model_dump(exclude_unset=True)
    for key, value in data.items():
        if value is None and key in required:
            continue
        setattr(obj, key, value)
    return data


def fill_english(obj: Any, *fields: str) -> None:
    """The app shows the `_en` text when its language is English: never leave it empty."""
    for field in fields:
        if not (getattr(obj, f"{field}_en") or "").strip():
            setattr(obj, f"{field}_en", getattr(obj, f"{field}_ar"))


def ensure_unique(db: Session, model, column: str, value: Any, *, exclude_id: int | None = None):
    col = getattr(model, column)
    stmt = select(model.id).where(col == value)
    if exclude_id is not None:
        stmt = stmt.where(model.id != exclude_id)
    if db.scalars(stmt).first() is not None:
        raise AppError(400, f"{column} already exists", code="DUPLICATE")


def get_or_404(db: Session, model, obj_id: int, name: str = "Item"):
    obj = db.get(model, obj_id)
    if obj is None:
        raise AppError(404, f"{name} not found", code="NOT_FOUND")
    return obj


def json_list(raw: str | None) -> list:
    try:
        value = json.loads(raw or "[]")
    except Exception:
        return []
    return value if isinstance(value, list) else []


def iso(value) -> str:
    return value.isoformat() if value else ""
