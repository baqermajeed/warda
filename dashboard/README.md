# Warda Dashboard

Admin control panel for the Warda app (Next.js 15 + Tailwind, RTL Arabic).

## Run locally

```bash
# 1) backend (from ../backend)
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

# 2) create an admin account (once)
python scripts/create_admin.py 07700000000 "StrongPass" "اسم المدير"

# 3) dashboard
cd dashboard
npm install
cp .env.local.example .env.local   # NEXT_PUBLIC_API_BASE=http://localhost:8000
npm run dev                         # http://localhost:3000
```

## What it manages

| Page | Shows up in the app |
|------|---------------------|
| الهدايا | All gifts, images, prices, filters, care steps, badges, «أحدث الهدايا» / «الأكثر شهرة» pins |
| التصنيفات | «اختر حسب» on the home screen |
| إعلانات الرئيسية | Home banner carousel + «استكشف» link |
| البطاقات والتغليف والإضافات | Basket: gift card, wrapping, add-ons |
| الطلبات | Order status (customer gets a notification) |
| الزبائن / حسابات الإدارة | Activate/deactivate accounts, admin access |
| الإشعارات | Bell screen in the app (all customers or one) |
| خدمة العملاء | Support tickets + replies (sent as notifications) |
| الأسئلة الشائعة / سياسة الخصوصية | Account page screens |
| الإعدادات | Support contacts, share texts, delivery fee & free-delivery threshold |

**Ranking:** «أحدث الهدايا» = newest by creation date. «الأكثر شهرة» = units sold (non-cancelled orders) × 2 + favorites.
Pinned gifts appear first in their section.
