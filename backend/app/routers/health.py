from __future__ import annotations

from fastapi import APIRouter
from sqlalchemy import text

from app.cache import redis_ok
from app.deps import DbSession

router = APIRouter(tags=["health"])


@router.get("/health")
def health(db: DbSession) -> dict:
    db_ok = False
    try:
        db.execute(text("SELECT 1"))
        db_ok = True
    except Exception:
        db_ok = False
    return {
        "ok": db_ok,
        "app": "warda",
        "database": db_ok,
        "redis": redis_ok(),
    }
