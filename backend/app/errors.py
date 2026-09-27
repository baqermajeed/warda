from typing import Any

from fastapi import HTTPException, Request
from fastapi.responses import JSONResponse


class AppError(HTTPException):
    def __init__(
        self,
        status_code: int,
        detail: str,
        code: str = "ERROR",
        headers: dict[str, str] | None = None,
    ) -> None:
        super().__init__(status_code=status_code, detail=detail, headers=headers)
        self.code = code


def error_payload(detail: str, code: str = "ERROR") -> dict[str, Any]:
    return {"detail": detail, "code": code}


async def app_error_handler(_request: Request, exc: AppError) -> JSONResponse:
    return JSONResponse(
        status_code=exc.status_code,
        content=error_payload(str(exc.detail), exc.code),
        headers=exc.headers,
    )


async def http_exception_handler(_request: Request, exc: HTTPException) -> JSONResponse:
    detail = exc.detail
    if isinstance(detail, list):
        # FastAPI validation-style detail lists
        msg = detail[0].get("msg") if detail and isinstance(detail[0], dict) else str(detail)
        code = "VALIDATION_ERROR"
    else:
        msg = str(detail)
        code = "HTTP_ERROR"
    return JSONResponse(
        status_code=exc.status_code,
        content=error_payload(msg, code),
        headers=exc.headers,
    )
