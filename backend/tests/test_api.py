from __future__ import annotations

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from app.db import Base, get_db
from app.main import app
from app.models import Product


@pytest.fixture()
def client():
    engine = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    TestingSessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)
    Base.metadata.create_all(bind=engine)

    def override_get_db():
        db = TestingSessionLocal()
        try:
            yield db
        finally:
            db.close()

    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as c:
        yield c
    app.dependency_overrides.clear()


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

    gen = app.dependency_overrides[get_db]()
    db = next(gen)
    product = Product(
        sku="T-1",
        title_ar="باقة",
        title_en="Bouquet",
        description_ar="x",
        description_en="x",
        price=120000,
        status="active",
        cover_image="/api/v1/media/p.jpg",
    )
    db.add(product)
    db.commit()
    db.refresh(product)
    product_id = product.id
    try:
        next(gen)
    except StopIteration:
        pass

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
