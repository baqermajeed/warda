from __future__ import annotations

from datetime import datetime

import pytest
from fastapi.testclient import TestClient
from pymongo import MongoClient

from app.config import settings
from app.main import app


def _mongo_db():
    return MongoClient(settings.mongodb_url)[settings.mongodb_db]


def _clear_db() -> None:
    db = _mongo_db()
    for name in db.list_collection_names():
        db.drop_collection(name)


@pytest.fixture()
def client():
    _clear_db()
    with TestClient(app) as c:
        yield c
    _clear_db()


def test_health(client):
    res = client.get("/health")
    assert res.status_code == 200
    assert res.json()["ok"] is True


def test_register_and_login_flow(client):
    phone = "07701234567"
    reg = client.post(
        "/api/v1/auth/register",
        json={
            "phone": phone,
            "password": "secret12",
            "name": "اختبار",
            "governorate": "gov_baghdad",
        },
    )
    assert reg.status_code == 200
    body = reg.json()
    assert body["access_token"]
    assert body["user"]["phone"] == phone

    me = client.get(
        "/api/v1/auth/me",
        headers={"Authorization": f"Bearer {body['access_token']}"},
    )
    assert me.status_code == 200
    assert me.json()["name"] == "اختبار"

    login = client.post(
        "/api/v1/auth/login",
        json={"phone": phone, "password": "secret12"},
    )
    assert login.status_code == 200
    assert login.json()["access_token"]

    bad = client.post(
        "/api/v1/auth/login",
        json={"phone": phone, "password": "wrongpass"},
    )
    assert bad.status_code == 401


def test_lookups(client):
    res = client.get("/api/v1/lookups")
    assert res.status_code == 200
    assert "governorates" in res.json()


def test_cart_and_order_flow(client):
    now = datetime.utcnow()
    product_id = 9001
    _mongo_db().products.insert_one(
        {
            "_id": product_id,
            "sku": "T-1",
            "title_ar": "باقة",
            "title_en": "Bouquet",
            "description_ar": "x",
            "description_en": "x",
            "price": 120000,
            "rating": "4.5",
            "care_steps_ar": "",
            "care_steps_en": "",
            "badges_json": "[]",
            "is_latest": False,
            "is_popular": False,
            "status": "active",
            "cover_image": "/api/v1/media/p.jpg",
            "images": [],
            "created_at": now,
            "updated_at": now,
        }
    )

    phone = "07709876543"
    tokens = client.post(
        "/api/v1/auth/register",
        json={
            "phone": phone,
            "password": "secret12",
            "name": "Buyer",
            "governorate": "gov_baghdad",
        },
    ).json()
    headers = {"Authorization": f"Bearer {tokens['access_token']}"}

    add = client.post(
        "/api/v1/cart/items",
        headers=headers,
        json={"product_id": product_id, "qty": 1},
    )
    assert add.status_code == 200
    assert add.json()["pricing"]["delivery_price"] == 0

    order = client.post(
        "/api/v1/orders",
        headers=headers,
        json={
            "recipient_name": "Ali",
            "recipient_phone": "07701112233",
            "governorate": "gov_baghdad",
            "landmark": "near park",
            "payment_method": "cod",
        },
    )
    assert order.status_code == 200
    assert order.json()["total"] == 120000

    listing = client.get("/api/v1/orders", headers=headers)
    assert listing.status_code == 200
    assert listing.json()["total"] == 1
