from __future__ import annotations

from typing import Annotated

from fastapi import Depends, Header
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from app.errors import AppError
from app.models import User
from app.security import decode_access_token

bearer_scheme = HTTPBearer(auto_error=False)


async def get_current_user(
    credentials: Annotated[HTTPAuthorizationCredentials | None, Depends(bearer_scheme)],
) -> User:
    if credentials is None or not credentials.credentials:
        raise AppError(401, "Not authenticated", code="UNAUTHORIZED")
    try:
        payload = decode_access_token(credentials.credentials)
        user_id = int(payload["sub"])
    except Exception as exc:
        raise AppError(401, "Invalid or expired token", code="UNAUTHORIZED") from exc

    user = await User.find_one(User.id == user_id)
    if user is None or not user.is_active:
        raise AppError(401, "User inactive", code="UNAUTHORIZED")
    return user


async def get_optional_user(
    credentials: Annotated[HTTPAuthorizationCredentials | None, Depends(bearer_scheme)],
) -> User | None:
    if credentials is None or not credentials.credentials:
        return None
    try:
        return await get_current_user(credentials)
    except AppError:
        return None


CurrentUser = Annotated[User, Depends(get_current_user)]
OptionalUser = Annotated[User | None, Depends(get_optional_user)]


def client_ip(x_forwarded_for: Annotated[str | None, Header()] = None) -> str:
    if x_forwarded_for:
        return x_forwarded_for.split(",")[0].strip()
    return ""


def get_admin_user(user: CurrentUser) -> User:
    if not user.is_admin:
        raise AppError(403, "Admin only", code="FORBIDDEN")
    return user


AdminUser = Annotated[User, Depends(get_admin_user)]
