from __future__ import annotations

import uuid
from pathlib import Path

from fastapi import APIRouter, File, UploadFile
from fastapi.responses import FileResponse

from app.config import settings
from app.deps import CurrentUser
from app.errors import AppError

router = APIRouter(tags=["media"])

ALLOWED_EXT = {".jpg", ".jpeg", ".png", ".webp"}
ALLOWED_MIME = {"image/jpeg", "image/png", "image/webp"}


@router.post("/uploads/image")
async def upload_image(user: CurrentUser, file: UploadFile = File(...)) -> dict:
    if not user.is_admin:
        raise AppError(403, "Admin only", code="FORBIDDEN")
    content = await file.read()
    if len(content) > settings.upload_max_bytes:
        raise AppError(400, "File too large", code="FILE_TOO_LARGE")
    ext = Path(file.filename or "").suffix.lower()
    if ext not in ALLOWED_EXT:
        raise AppError(400, "Invalid file type", code="INVALID_FILE")
    if file.content_type and file.content_type not in ALLOWED_MIME:
        raise AppError(400, "Invalid mime type", code="INVALID_FILE")

    upload_dir = Path(settings.upload_dir)
    upload_dir.mkdir(parents=True, exist_ok=True)
    name = f"{uuid.uuid4().hex}{ext}"
    path = upload_dir / name
    path.write_bytes(content)
    return {"filename": name, "url": f"/api/v1/media/{name}"}


@router.get("/media/{name}")
def get_media(name: str):
    if ".." in name or "/" in name or "\\" in name:
        raise AppError(400, "Invalid name", code="INVALID_NAME")
    path = Path(settings.upload_dir) / name
    if not path.exists():
        raise AppError(404, "Not found", code="NOT_FOUND")
    return FileResponse(path)
