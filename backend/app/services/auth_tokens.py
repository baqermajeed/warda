from __future__ import annotations

import json
from datetime import timedelta

from app.config import settings, utcnow
from app.models import RefreshToken, User
from app.security import (
    create_access_token,
    generate_refresh_token,
    hash_token,
)


async def issue_tokens(user: User) -> dict:
    access = create_access_token(subject=str(user.id))
    raw_refresh = generate_refresh_token()
    row = RefreshToken(
        user_id=user.id,
        token_hash=hash_token(raw_refresh),
        expires_at=utcnow() + timedelta(days=settings.refresh_token_days),
    )
    await row.insert()
    return {
        "access_token": access,
        "refresh_token": raw_refresh,
        "token_type": "bearer",
        "expires_in": settings.access_token_minutes * 60,
    }


async def rotate_refresh_token(raw_refresh: str) -> tuple[User, dict]:
    from app.errors import AppError

    token_hash = hash_token(raw_refresh)
    row = await RefreshToken.find_one(RefreshToken.token_hash == token_hash)
    if row is None or row.revoked_at is not None:
        raise AppError(401, "Invalid refresh token", code="INVALID_REFRESH")
    if row.expires_at < utcnow():
        raise AppError(401, "Refresh token expired", code="REFRESH_EXPIRED")

    user = await User.find_one(User.id == row.user_id)
    if user is None or not user.is_active:
        raise AppError(401, "User inactive", code="USER_INACTIVE")

    row.revoked_at = utcnow()
    await row.save()
    tokens = await issue_tokens(user)
    return user, tokens


async def revoke_refresh_token(raw_refresh: str | None) -> None:
    if not raw_refresh:
        return
    token_hash = hash_token(raw_refresh)
    row = await RefreshToken.find_one(RefreshToken.token_hash == token_hash)
    if row and row.revoked_at is None:
        row.revoked_at = utcnow()
        await row.save()


async def revoke_all_user_tokens(user_id: int) -> None:
    rows = await RefreshToken.find(
        RefreshToken.user_id == user_id,
        RefreshToken.revoked_at == None,  # noqa: E711
    ).to_list()
    now = utcnow()
    for row in rows:
        row.revoked_at = now
        await row.save()


def parse_json_list(raw: str) -> list:
    try:
        data = json.loads(raw or "[]")
        return data if isinstance(data, list) else []
    except Exception:
        return []


def parse_json_obj(raw: str) -> dict:
    try:
        data = json.loads(raw or "{}")
        return data if isinstance(data, dict) else {}
    except Exception:
        return {}
