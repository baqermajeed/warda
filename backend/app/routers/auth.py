from __future__ import annotations

from fastapi import APIRouter, Request

from app.cache import incr_with_ttl
from app.config import settings, utcnow
from app.deps import CurrentUser, client_ip
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
async def login(payload: LoginIn, request: Request) -> TokenOut:
    phone = require_iraqi_phone(payload.phone)
    ip = client_ip(request.headers.get("x-forwarded-for"))
    if incr_with_ttl(f"login:rl:ip:{ip or 'unknown'}", 60) > 20:
        raise AppError(429, "Too many login attempts", code="LOGIN_RATE_LIMIT")
    if incr_with_ttl(f"login:rl:phone:{phone}", 60) > 10:
        raise AppError(429, "Too many login attempts", code="LOGIN_RATE_LIMIT")

    user = await User.find_one(User.phone == phone)
    if (
        user is None
        or not user.is_active
        or not user.password_hash
        or not verify_password(payload.password, user.password_hash)
    ):
        raise AppError(401, "Invalid phone or password", code="INVALID_CREDENTIALS")

    tokens = await issue_tokens(user)
    return TokenOut(**tokens, user=_user_out(user))


@router.post("/register", response_model=TokenOut)
async def register(payload: RegisterIn) -> TokenOut:
    phone = require_iraqi_phone(payload.phone)
    if len(payload.password) < 6:
        raise AppError(400, "Password must be at least 6 characters", code="WEAK_PASSWORD")

    existing = await User.find_one(User.phone == phone)
    if existing and existing.is_active:
        raise AppError(400, "Phone already registered", code="PHONE_EXISTS")

    if existing and not existing.is_active:
        existing.is_active = True
        existing.password_hash = hash_password(payload.password)
        existing.name = payload.name.strip()
        existing.governorate = payload.governorate
        existing.updated_at = utcnow()
        await existing.save()
        tokens = await issue_tokens(existing)
        return TokenOut(**tokens, user=_user_out(existing))

    user = User(
        phone=phone,
        password_hash=hash_password(payload.password),
        name=payload.name.strip(),
        governorate=payload.governorate,
    )
    await user.insert()
    tokens = await issue_tokens(user)
    return TokenOut(**tokens, user=_user_out(user))


@router.post("/refresh", response_model=TokenOut)
async def refresh(payload: RefreshIn) -> TokenOut:
    user, tokens = await rotate_refresh_token(payload.refresh_token)
    return TokenOut(**tokens, user=_user_out(user))


@router.post("/logout", response_model=OkOut)
async def logout(payload: LogoutIn, user: CurrentUser) -> OkOut:
    await revoke_refresh_token(payload.refresh_token)
    return OkOut()


@router.get("/me", response_model=UserOut)
async def me(user: CurrentUser) -> UserOut:
    return _user_out(user)


@router.patch("/me", response_model=UserOut)
async def update_me(payload: ProfileUpdateIn, user: CurrentUser) -> UserOut:
    if payload.name is not None:
        user.name = payload.name.strip()
    if payload.governorate is not None:
        user.governorate = payload.governorate
    if payload.notifications_enabled is not None:
        user.notifications_enabled = payload.notifications_enabled
    if payload.locale is not None:
        user.locale = payload.locale
    if payload.email is not None:
        user.email = payload.email
    user.updated_at = utcnow()
    await user.save()
    return _user_out(user)


@router.delete("/me", response_model=OkOut)
async def delete_me(user: CurrentUser) -> OkOut:
    await revoke_all_user_tokens(user.id)
    user.is_active = False
    user.phone = f"deleted_{user.id}_{user.phone}"
    user.updated_at = utcnow()
    await user.save()
    return OkOut()
