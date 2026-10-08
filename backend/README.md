# Warda Backend

FastAPI API for the Warda gift shop Flutter app. Data is stored in **MongoDB** (Motor + Beanie).

## Quick start (Docker)

```bash
cd backend
docker compose up --build -d
docker compose exec api python scripts/seed.py
```

API: http://localhost:8000  
Docs: http://localhost:8000/docs  
Health: http://localhost:8000/health

## Local (MongoDB on your machine)

1. Install and start MongoDB (default `mongodb://127.0.0.1:27017`).
2. Set up Python:

```bash
cd backend
python -m venv .venv
# Windows:
.venv\Scripts\activate
pip install -r requirements.txt
copy .env.example .env
uvicorn app.main:app --reload --port 8000
python scripts/seed.py
```

Environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `MONGODB_URL` | `mongodb://127.0.0.1:27017` | MongoDB connection string |
| `MONGODB_DB` | `warda` | Database name |

## Auth flow

1. `POST /api/v1/auth/register` `{ "phone", "password", "name", "governorate" }`
2. `POST /api/v1/auth/login` `{ "phone", "password" }`

Use `Authorization: Bearer <access_token>` on protected routes.
Refresh via `POST /api/v1/auth/refresh`.

## Main modules

| Area | Prefix |
|------|--------|
| Auth | `/api/v1/auth` |
| Home/catalog | `/api/v1/home`, `/products`, `/categories`, `/lookups` |
| Favorites | `/api/v1/favorites` |
| Cart + options | `/api/v1/cart`, `/gift-cards`, `/wraps`, `/addons` |
| Orders | `/api/v1/orders` |
| Special gift | `/api/v1/special-gift` |
| Reminders | `/api/v1/reminders` |
| FAQ/Privacy/Support/Share | `/api/v1/faq`, `/privacy`, `/support`, `/app/share` |

## Tests

Requires a running MongoDB instance (same host as `MONGODB_URL`). Tests use database `warda_pytest` by default.

```bash
pytest
```

## Notes

- IQD integer prices; free delivery at >= 100,000
- Passwords hashed with Argon2
- Redis used for rate-limit/cache when available; in-memory fallback otherwise
- Integer `id` fields in API responses are preserved for Flutter compatibility (stored as document `_id` in MongoDB)

## Admin dashboard API

All routes under `/api/v1/admin` require an admin account (`users.is_admin`).

```bash
python scripts/create_admin.py 07700000000 "StrongPass" "Admin"
```

- `POST /api/v1/admin/login` — admin-only login (returns access + refresh tokens)
- Catalog: `/admin/categories`, `/admin/banners`, `/admin/products`, `/admin/options/{gift-cards|wraps|addons}`
- Sales: `/admin/stats`, `/admin/orders` (+ `PATCH /{id}/status`), `/admin/users`, `/admin/admins`
- Content: `/admin/notifications`, `/admin/faq`, `/admin/privacy`, `/admin/support/tickets`, `/admin/settings`
- Images: `POST /api/v1/uploads/image` (admin) → served from `/api/v1/media/{name}`

Home ranking: «أحدث الهدايا» = newest first; «الأكثر شهرة» = sold units × 2 + favorites.
`products.is_latest` / `is_popular` are manual pins from the dashboard.

The web dashboard lives in `../dashboard` (see its README).

**Note:** admin/notifications services from origin still need a Mongo/Beanie port — they currently assume SQLAlchemy.
