# Warda Backend

FastAPI API for the Warda gift shop Flutter app.

## Quick start (Docker)

```bash
cd backend
docker compose up --build -d
docker compose exec api python scripts/seed.py
```

API: http://localhost:8000  
Docs: http://localhost:8000/docs  
Health: http://localhost:8000/health

## Local (SQLite, no Docker)

```bash
cd backend
python -m venv .venv
# Windows:
.venv\Scripts\activate
pip install -r requirements.txt
copy .env.example .env
# set DATABASE_URL=sqlite:///./warda.db in .env
uvicorn app.main:app --reload --port 8000
python scripts/seed.py
```

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

## Notes

- IQD integer prices; free delivery at >= 100,000
- Passwords hashed with Argon2
- Redis used for rate-limit/cache when available; in-memory fallback otherwise
