from __future__ import annotations

import uuid
from contextlib import asynccontextmanager
from pathlib import Path

from beanie import init_beanie
from fastapi import FastAPI, Request
from fastapi.exceptions import HTTPException, RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from fastapi.responses import JSONResponse

from app.config import settings
from app.db import close_mongodb, connect_mongodb, get_database
from app.errors import AppError, app_error_handler, error_payload, http_exception_handler
from app.models import ALL_DOCUMENT_MODELS
from app.routers import (
    auth,
    cart,
    catalog,
    cms,
    favorites,
    health,
    media,
    orders,
    reminders,
    special_gift,
)


@asynccontextmanager
async def lifespan(_app: FastAPI):
    Path(settings.upload_dir).mkdir(parents=True, exist_ok=True)
    await connect_mongodb()
    await init_beanie(database=get_database(), document_models=ALL_DOCUMENT_MODELS)
    yield
    await close_mongodb()


app = FastAPI(title=settings.app_name, version="1.0.0", lifespan=lifespan)

# TrustedHost فقط في الإنتاج — في التطوير يمنع الوصول عبر IP الهاتف الحقيقي.
if not settings.is_dev and settings.hosts and settings.hosts != ["*"]:
    hosts = list(settings.hosts)
    if "testserver" not in hosts:
        hosts.append("testserver")
    app.add_middleware(TrustedHostMiddleware, allowed_hosts=hosts)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.middleware("http")
async def request_id_middleware(request: Request, call_next):
    request_id = request.headers.get("X-Request-ID") or uuid.uuid4().hex
    response = await call_next(request)
    response.headers["X-Request-ID"] = request_id
    return response


@app.exception_handler(AppError)
async def _app_error(request: Request, exc: AppError):
    return await app_error_handler(request, exc)


@app.exception_handler(HTTPException)
async def _http_error(request: Request, exc: HTTPException):
    return await http_exception_handler(request, exc)


@app.exception_handler(RequestValidationError)
async def _validation_error(_request: Request, exc: RequestValidationError):
    msg = "Validation error"
    if exc.errors():
        msg = str(exc.errors()[0].get("msg", msg))
    return JSONResponse(status_code=422, content=error_payload(msg, "VALIDATION_ERROR"))


app.include_router(health.router)
app.include_router(auth.router, prefix="/api/v1")
app.include_router(catalog.router, prefix="/api/v1")
app.include_router(favorites.router, prefix="/api/v1")
app.include_router(cart.router, prefix="/api/v1")
app.include_router(orders.router, prefix="/api/v1")
app.include_router(special_gift.router, prefix="/api/v1")
app.include_router(reminders.router, prefix="/api/v1")
app.include_router(cms.router, prefix="/api/v1")
app.include_router(media.router, prefix="/api/v1")
