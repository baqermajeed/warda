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


def _register(client, phone: str) -> dict:
    tokens = client.post(
        "/api/v1/auth/register",
        json={
            "phone": phone,
            "password": "secret12",
            "name": "Tester",
            "governorate": "gov_baghdad",
        },
    ).json()
    return {"Authorization": f"Bearer {tokens['access_token']}"}


def _add_products(rows: list[tuple[str, str | None, str | None]]) -> list[int]:
    """rows: (sku, gift_type_tag, occasion_tag)"""
    gen = app.dependency_overrides[get_db]()
    db = next(gen)
    ids = []
    for sku, gtype, occasion in rows:
        p = Product(
            sku=sku,
            title_ar=sku,
            title_en=sku,
            price=10000,
            status="active",
            gift_type_tag=gtype,
            occasion_tag=occasion,
        )
        db.add(p)
        db.commit()
        ids.append(p.id)
    try:
        next(gen)
    except StopIteration:
        pass
    return ids


def test_lookups_cover_app_filters(client):
    data = client.get("/api/v1/lookups").json()
    filters = {f["id"]: [o["id"] for o in f["options"]] for f in data["filters"]}
    assert "sweets" in filters["gift_type"]
    assert "other_occ" in filters["occasion"]
    assert [c["id"] for c in data["favorite_categories"]][1] == "bouquets"
    assert "lavender" in [c["id"] for c in data["addon_categories"]]
    assert data["delivery_fee"] == 5000


def test_gift_type_and_occasion_groups(client):
    _add_products(
        [
            ("S-1", "cake", "birthday"),
            ("S-2", "chocolate", "mothers"),
            ("S-3", "flowers", "love"),
            ("S-4", "lavender", "wedding"),
        ]
    )
    sweets = client.get("/api/v1/products", params={"gift_type": "sweets"}).json()
    assert sweets["total"] == 2
    flowers = client.get("/api/v1/products", params={"gift_type": "flowers"}).json()
    assert flowers["total"] == 2
    other = client.get("/api/v1/products", params={"occasion": "other_occ"}).json()
    assert other["total"] == 2


def test_favorites_category_groups(client):
    headers = _register(client, "07701230001")
    ids = _add_products([("F-1", "flowers", None), ("F-2", "cherry", None), ("F-3", "cake", None)])
    for pid in ids:
        assert client.put(f"/api/v1/favorites/{pid}", headers=headers).status_code == 200
    bouquets = client.get(
        "/api/v1/favorites", headers=headers, params={"category": "bouquets"}
    ).json()
    assert bouquets["total"] == 2
    cherry = client.get("/api/v1/favorites", headers=headers, params={"category": "cherry"}).json()
    assert cherry["total"] == 1


def test_profile_update_phone_and_settings(client):
    headers = _register(client, "07701230002")
    _register(client, "07701230003")
    res = client.patch(
        "/api/v1/auth/me",
        headers=headers,
        json={"phone": "0770 123 0009", "notifications_enabled": False, "locale": "en"},
    )
    assert res.status_code == 200
    body = res.json()
    assert body["phone"] == "07701230009"
    assert body["notifications_enabled"] is False
    assert body["locale"] == "en"

    taken = client.patch("/api/v1/auth/me", headers=headers, json={"phone": "07701230003"})
    assert taken.status_code == 400

    bad = client.patch("/api/v1/auth/me", headers=headers, json={"phone": "123"})
    assert bad.status_code == 400


def test_product_share(client):
    (pid,) = _add_products([("SH-1", "flowers", None)])
    res = client.get(f"/api/v1/products/{pid}/share")
    assert res.status_code == 200
    assert res.json()["url"].endswith(f"/{pid}")
    assert client.get("/api/v1/products/99999/share").status_code == 404


def test_notifications_from_order_and_reminder(client):
    headers = _register(client, "07701230004")
    (pid,) = _add_products([("N-1", "flowers", None)])
    client.post("/api/v1/cart/items", headers=headers, json={"product_id": pid, "qty": 1})
    order = client.post(
        "/api/v1/orders",
        headers=headers,
        json={
            "recipient_name": "Ali",
            "recipient_phone": "07701112233",
            "governorate": "gov_baghdad",
        },
    )
    assert order.status_code == 200
    assert order.json()["status"] == "pending"

    from datetime import date

    client.post(
        "/api/v1/reminders",
        headers=headers,
        json={
            "person_name": "Sara",
            "type_id": "birthday",
            "date": date.today().isoformat(),
            "remind_days_before": 3,
        },
    )

    count = client.get("/api/v1/notifications/unread-count", headers=headers).json()["count"]
    assert count == 2
    listing = client.get("/api/v1/notifications", headers=headers).json()
    assert listing["total"] == 2
    types = {n["type"] for n in listing["items"]}
    assert types == {"order", "reminder"}

    first = listing["items"][0]["id"]
    assert client.post(f"/api/v1/notifications/{first}/read", headers=headers).status_code == 200
    assert client.get("/api/v1/notifications/unread-count", headers=headers).json()["count"] == 1
    client.post("/api/v1/notifications/read-all", headers=headers)
    assert client.get("/api/v1/notifications/unread-count", headers=headers).json()["count"] == 0
    # Reminder notification is not duplicated on later syncs.
    assert client.get("/api/v1/notifications", headers=headers).json()["total"] == 2


def test_order_status_requires_admin(client):
    headers = _register(client, "07701230005")
    res = client.patch("/api/v1/orders/1/status", headers=headers, json={"status": "shipping"})
    assert res.status_code == 403
