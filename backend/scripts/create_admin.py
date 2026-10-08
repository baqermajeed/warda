"""Create (or promote) an admin account for the dashboard.

Usage:
    python scripts/create_admin.py 07700000000 "StrongPass123" "اسم المدير"
"""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from sqlalchemy import select  # noqa: E402

from app.db import Base, SessionLocal, engine  # noqa: E402
from app.models import User  # noqa: E402
from app.security import hash_password  # noqa: E402
from app.services.phone import IRAQI_PHONE_RE, normalize_iraqi_phone  # noqa: E402


def main() -> None:
    if len(sys.argv) < 3:
        print(__doc__)
        raise SystemExit(1)
    phone = normalize_iraqi_phone(sys.argv[1])
    password = sys.argv[2]
    name = sys.argv[3] if len(sys.argv) > 3 else "Admin"
    if not IRAQI_PHONE_RE.match(phone):
        raise SystemExit("Invalid Iraqi phone number (expected 07XXXXXXXXX)")
    if len(password) < 6:
        raise SystemExit("Password must be at least 6 characters")

    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        user = db.scalars(select(User).where(User.phone == phone)).first()
        created = user is None
        if user is None:
            user = User(phone=phone)
            db.add(user)
        user.name = name
        user.password_hash = hash_password(password)
        user.is_admin = True
        user.is_active = True
        db.commit()
        print(f"{'Created' if created else 'Updated'} admin {phone}")
    finally:
        db.close()


if __name__ == "__main__":
    main()
