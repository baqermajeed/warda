"""Admin dashboard API — everything under `/api/v1/admin` requires an admin account."""

from __future__ import annotations

from fastapi import APIRouter, Request
from sqlalchemy import select

from app.cache import incr_with_ttl
from app.deps import AdminUser, DbSession, client_ip
from app.errors import AppError
from app.models import User
from app.routers.admin import catalog, content, sales
from app.schemas import TokenOut, UserOut
from app.schemas.admin import AdminLoginIn
from app.security import verify_password
from app.services.auth_tokens import issue_tokens
from app.services.phone import normalize_iraqi_phone

router = APIRouter(prefix="/admin", tags=["admin"])


@router.post("/login", response_model=TokenOut)
def admin_login(payload: AdminLoginIn, request: Request, db: DbSession) -> TokenOut:
    phone = normalize_iraqi_phone(payload.phone)
    ip = client_ip(request.headers.get("x-forwarded-for"))
    if incr_with_ttl(f"admin-login:rl:{ip or 'unknown'}", 60) > 15:
        raise AppError(429, "Too many login attempts", code="LOGIN_RATE_LIMIT")
    user = db.scalars(select(User).where(User.phone == phone)).first()
    if (
        user is None
        or not user.is_active
        or not user.password_hash
        or not verify_password(payload.password, user.password_hash)
    ):
        raise AppError(401, "Invalid phone or password", code="INVALID_CREDENTIALS")
    if not user.is_admin:
        raise AppError(403, "This account is not an admin", code="FORBIDDEN")
    tokens = issue_tokens(db, user)
    return TokenOut(**tokens, user=UserOut.model_validate(user))


@router.get("/me", response_model=UserOut)
def admin_me(admin: AdminUser) -> UserOut:
    return UserOut.model_validate(admin)


router.include_router(catalog.router)
router.include_router(sales.router)
router.include_router(content.router)
