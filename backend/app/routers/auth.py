from __future__ import annotations

from fastapi import APIRouter, Request
from sqlalchemy import select

from app.cache import incr_with_ttl
from app.config import settings
from app.deps import CurrentUser, DbSession, client_ip
from app.errors import AppError
from app.models import User
from app.schemas import (
    LoginIn,
    LogoutIn,
    OkOut,
    ProfileUpdateIn,
    RefreshIn,
    RegisterIn,
    TokenOut,
    UserOut,
)
from app.security import hash_password, verify_password
from app.services.auth_tokens import (
    issue_tokens,
    revoke_all_user_tokens,
    revoke_refresh_token,
    rotate_refresh_token,
)
from app.services.phone import require_iraqi_phone

router = APIRouter(prefix="/auth", tags=["auth"])


def _user_out(user: User) -> UserOut:
    return UserOut.model_validate(user)


@router.post("/login", response_model=TokenOut)
def login(payload: LoginIn, request: Request, db: DbSession) -> TokenOut:
    phone = require_iraqi_phone(payload.phone)
    ip = client_ip(request.headers.get("x-forwarded-for"))
    if incr_with_ttl(f"login:rl:ip:{ip or 'unknown'}", 60) > 20:
        raise AppError(429, "Too many login attempts", code="LOGIN_RATE_LIMIT")
    if incr_with_ttl(f"login:rl:phone:{phone}", 60) > 10:
        raise AppError(429, "Too many login attempts", code="LOGIN_RATE_LIMIT")

    user = db.scalars(select(User).where(User.phone == phone)).first()
    if (
        user is None
        or not user.is_active
        or not user.password_hash
        or not verify_password(payload.password, user.password_hash)
    ):
        raise AppError(401, "Invalid phone or password", code="INVALID_CREDENTIALS")

    tokens = issue_tokens(db, user)
    return TokenOut(**tokens, user=_user_out(user))


@router.post("/register", response_model=TokenOut)
def register(payload: RegisterIn, db: DbSession) -> TokenOut:
    phone = require_iraqi_phone(payload.phone)
    if len(payload.password) < 6:
        raise AppError(400, "Password must be at least 6 characters", code="WEAK_PASSWORD")

    existing = db.scalars(select(User).where(User.phone == phone)).first()
    if existing and existing.is_active:
        raise AppError(400, "Phone already registered", code="PHONE_EXISTS")

    if existing and not existing.is_active:
        existing.is_active = True
        existing.password_hash = hash_password(payload.password)
        existing.name = payload.name.strip()
        existing.governorate = payload.governorate
        db.commit()
        db.refresh(existing)
        tokens = issue_tokens(db, existing)
        return TokenOut(**tokens, user=_user_out(existing))

    user = User(
        phone=phone,
        password_hash=hash_password(payload.password),
        name=payload.name.strip(),
        governorate=payload.governorate,
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    tokens = issue_tokens(db, user)
    return TokenOut(**tokens, user=_user_out(user))


@router.post("/refresh", response_model=TokenOut)
def refresh(payload: RefreshIn, db: DbSession) -> TokenOut:
    user, tokens = rotate_refresh_token(db, payload.refresh_token)
    return TokenOut(**tokens, user=_user_out(user))


@router.post("/logout", response_model=OkOut)
def logout(payload: LogoutIn, db: DbSession, user: CurrentUser) -> OkOut:
    revoke_refresh_token(db, payload.refresh_token)
    return OkOut()


@router.get("/me", response_model=UserOut)
def me(user: CurrentUser) -> UserOut:
    return _user_out(user)


@router.patch("/me", response_model=UserOut)
def update_me(payload: ProfileUpdateIn, db: DbSession, user: CurrentUser) -> UserOut:
    if payload.name is not None:
        user.name = payload.name.strip()
    if payload.phone is not None:
        phone = require_iraqi_phone(payload.phone)
        if phone != user.phone:
            taken = db.scalars(
                select(User).where(User.phone == phone, User.id != user.id)
            ).first()
            if taken is not None:
                raise AppError(400, "Phone already registered", code="PHONE_EXISTS")
            user.phone = phone
    if payload.governorate is not None:
        user.governorate = payload.governorate
    if payload.notifications_enabled is not None:
        user.notifications_enabled = payload.notifications_enabled
    if payload.locale is not None:
        user.locale = payload.locale
    if payload.email is not None:
        user.email = payload.email
    db.commit()
    db.refresh(user)
    return _user_out(user)


@router.delete("/me", response_model=OkOut)
def delete_me(db: DbSession, user: CurrentUser) -> OkOut:
    revoke_all_user_tokens(db, user.id)
    user.is_active = False
    user.phone = f"deleted_{user.id}_{user.phone}"
    db.commit()
    return OkOut()
