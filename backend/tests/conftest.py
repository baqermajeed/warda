from __future__ import annotations

import os

# Use isolated DB for tests before app settings load.
os.environ.setdefault("MONGODB_URL", "mongodb://127.0.0.1:27017")
os.environ.setdefault("MONGODB_DB", "warda_pytest")
os.environ.setdefault("APP_ENV", "test")
