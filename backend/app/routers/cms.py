from __future__ import annotations

from fastapi import APIRouter
from sqlalchemy import select

from app.deps import CurrentUser, DbSession, OptionalUser
from app.models import FaqCategory, PrivacySection, SupportTicket
from app.schemas import OkOut, SupportTicketIn
from app.services.app_settings import get_setting
from sqlalchemy.orm import selectinload

router = APIRouter(tags=["cms"])


@router.get("/faq")
def faq(db: DbSession) -> dict:
    cats = db.scalars(
        select(FaqCategory)
        .options(selectinload(FaqCategory.items))
        .order_by(FaqCategory.sort_order, FaqCategory.id)
    ).all()
    return {
        "items": [
            {
                "id": c.id,
                "slug": c.slug,
                "title_ar": c.title_ar,
                "title_en": c.title_en,
                "items": [
                    {
                        "id": i.id,
                        "question_ar": i.question_ar,
                        "question_en": i.question_en,
                        "answer_ar": i.answer_ar,
                        "answer_en": i.answer_en,
                    }
                    for i in sorted(c.items, key=lambda x: (x.sort_order, x.id))
                ],
            }
            for c in cats
        ]
    }


@router.get("/privacy")
def privacy(db: DbSession) -> dict:
    rows = db.scalars(
        select(PrivacySection).order_by(PrivacySection.sort_order, PrivacySection.id)
    ).all()
    return {
        "items": [
            {
                "id": r.id,
                "slug": r.slug,
                "title_ar": r.title_ar,
                "title_en": r.title_en,
                "body_ar": r.body_ar,
                "body_en": r.body_en,
            }
            for r in rows
        ]
    }


@router.get("/support/contact")
def support_contact(db: DbSession) -> dict:
    return {
        key: get_setting(db, f"support.{key}")
        for key in ("phone", "whatsapp", "email", "hours_ar", "hours_en")
    }


@router.post("/support/tickets", response_model=OkOut)
def create_ticket(
    payload: SupportTicketIn,
    db: DbSession,
    user: OptionalUser,
) -> OkOut:
    ticket = SupportTicket(
        user_id=user.id if user else None,
        name=payload.name or (user.name if user else ""),
        phone=payload.phone or (user.phone if user else ""),
        subject=payload.subject.strip(),
        message=payload.message.strip(),
    )
    db.add(ticket)
    db.commit()
    return OkOut()


@router.get("/app/share")
def share(db: DbSession) -> dict:
    return {
        "url": get_setting(db, "share.url"),
        "message_ar": get_setting(db, "share.message_ar"),
        "message_en": get_setting(db, "share.message_en"),
    }
