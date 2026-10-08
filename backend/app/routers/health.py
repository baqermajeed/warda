from __future__ import annotations

from fastapi import APIRouter

from app.cache import redis_ok
from app.db import ping_mongodb

router = APIRouter(tags=["health"])


@router.get("/health")
async def health() -> dict:
    db_ok = await ping_mongodb()
    return {
        "ok": db_ok,
        "app": "warda",
        "database": db_ok,
        "redis": redis_ok(),
    }
