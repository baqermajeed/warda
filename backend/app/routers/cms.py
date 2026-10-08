from __future__ import annotations

from fastapi import APIRouter

from app.deps import OptionalUser
from app.models import AppSetting, FaqCategory, PrivacySection, SupportTicket
from app.schemas import OkOut, SupportTicketIn

router = APIRouter(tags=["cms"])


@router.get("/faq")
async def faq() -> dict:
    cats = await FaqCategory.find().sort("+sort_order", "+id").to_list()
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
async def privacy() -> dict:
    rows = await PrivacySection.find().sort("+sort_order", "+id").to_list()
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
async def support_contact() -> dict:
    defaults = {
        "phone": "+9647700000000",
        "whatsapp": "+9647700000000",
        "email": "support@warda.app",
        "hours_ar": "يومياً 9 ص – 9 م",
        "hours_en": "Daily 9 AM – 9 PM",
    }
    for key in list(defaults):
        row = await AppSetting.find_one(AppSetting.key == f"support.{key}")
        if row:
            defaults[key] = row.value
    return defaults


@router.post("/support/tickets", response_model=OkOut)
async def create_ticket(
    payload: SupportTicketIn,
    user: OptionalUser,
) -> OkOut:
    ticket = SupportTicket(
        user_id=user.id if user else None,
        name=payload.name or (user.name if user else ""),
        phone=payload.phone or (user.phone if user else ""),
        subject=payload.subject.strip(),
        message=payload.message.strip(),
    )
    await ticket.insert()
    return OkOut()


@router.get("/app/share")
async def share() -> dict:
    url = await AppSetting.find_one(AppSetting.key == "share.url")
    message_ar = await AppSetting.find_one(AppSetting.key == "share.message_ar")
    message_en = await AppSetting.find_one(AppSetting.key == "share.message_en")
    return {
        "url": url.value if url else "https://warda.app/download",
        "message_ar": message_ar.value
        if message_ar
        else "جرب تطبيق وردة للهدايا والزهور!",
        "message_en": message_en.value
        if message_en
        else "Try Warda — gifts and flowers delivered!",
    }
