from __future__ import annotations

import json
from datetime import timedelta

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.config import settings, utcnow
from app.models import RefreshToken, User
from app.security import (
    create_access_token,
    generate_refresh_token,
    hash_token,
)


def issue_tokens(db: Session, user: User) -> dict:
    access = create_access_token(subject=str(user.id))
    raw_refresh = generate_refresh_token()
    row = RefreshToken(
        user_id=user.id,
        token_hash=hash_token(raw_refresh),
        expires_at=utcnow() + timedelta(days=settings.refresh_token_days),
    )
    db.add(row)
    db.commit()
    return {
        "access_token": access,
        "refresh_token": raw_refresh,
        "token_type": "bearer",
        "expires_in": settings.access_token_minutes * 60,
    }


def rotate_refresh_token(db: Session, raw_refresh: str) -> tuple[User, dict]:
    from app.errors import AppError

    token_hash = hash_token(raw_refresh)
    row = db.scalars(
        select(RefreshToken).where(RefreshToken.token_hash == token_hash)
    ).first()
    if row is None or row.revoked_at is not None:
        raise AppError(401, "Invalid refresh token", code="INVALID_REFRESH")
    if row.expires_at < utcnow():
        raise AppError(401, "Refresh token expired", code="REFRESH_EXPIRED")

    user = db.get(User, row.user_id)
    if user is None or not user.is_active:
        raise AppError(401, "User inactive", code="USER_INACTIVE")

    row.revoked_at = utcnow()
    tokens = issue_tokens(db, user)
    return user, tokens


def revoke_refresh_token(db: Session, raw_refresh: str | None) -> None:
    if not raw_refresh:
        return
    token_hash = hash_token(raw_refresh)
    row = db.scalars(
        select(RefreshToken).where(RefreshToken.token_hash == token_hash)
    ).first()
    if row and row.revoked_at is None:
        row.revoked_at = utcnow()
        db.commit()


def revoke_all_user_tokens(db: Session, user_id: int) -> None:
    rows = db.scalars(
        select(RefreshToken).where(
            RefreshToken.user_id == user_id,
            RefreshToken.revoked_at.is_(None),
        )
    ).all()
    now = utcnow()
    for row in rows:
        row.revoked_at = now
    db.commit()


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
