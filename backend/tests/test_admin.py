from __future__ import annotations

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine, select
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from app.db import Base, get_db
from app.main import app
from app.models import User
from app.cache import _memory
from app.routers.admin.common import bust_public_cache
from app.security import hash_password

ADMIN_PHONE = "07700000001"
ADMIN_PASS = "admin123"


@pytest.fixture()
def client():
    _memory.clear()  # in-memory cache + rate-limit counters
    engine = create_engine(
        "sqlite://", connect_args={"check_same_thread": False}, poolclass=StaticPool
    )
    Session = sessionmaker(bind=engine, autoflush=False, autocommit=False)
    Base.metadata.create_all(bind=engine)

    def override_get_db():
        db = Session()
        try:
            yield db
        finally:
            db.close()

    app.dependency_overrides[get_db] = override_get_db
    db = Session()
    db.add(
        User(
            phone=ADMIN_PHONE,
            name="Admin",
            password_hash=hash_password(ADMIN_PASS),
            is_admin=True,
        )
    )
    db.commit()
    db.close()
    with TestClient(app) as c:
        c.session_factory = Session
        yield c
    app.dependency_overrides.clear()


@pytest.fixture()
def admin(client) -> dict:
    res = client.post("/api/v1/admin/login", json={"phone": ADMIN_PHONE, "password": ADMIN_PASS})
    assert res.status_code == 200, res.text
    return {"Authorization": f"Bearer {res.json()['access_token']}"}


def _customer(client, phone: str = "07711111111") -> dict:
    res = client.post(
        "/api/v1/auth/register",
        json={"phone": phone, "password": "secret12", "name": "Customer", "governorate": "gov_basra"},
    )
    assert res.status_code == 200, res.text
    return {"Authorization": f"Bearer {res.json()['access_token']}"}


def _product(client, admin, **overrides) -> dict:
    body = {
        "sku": overrides.pop("sku", "P-1"),
        "title_ar": "باقة",
        "price": 50000,
        "images": ["/api/v1/media/a.jpg", "/api/v1/media/b.jpg"],
        "care_steps_ar": ["خطوة 1", " ", "خطوة 2"],
        "badges": [{"label": "product_badge_natural", "icon": "truck"}],
        **overrides,
    }
    res = client.post("/api/v1/admin/products", headers=admin, json=body)
    assert res.status_code == 200, res.text
    return res.json()


def test_admin_login_rules(client):
    _customer(client)
    res = client.post("/api/v1/admin/login", json={"phone": "07711111111", "password": "secret12"})
    assert res.status_code == 403
    res = client.post("/api/v1/admin/login", json={"phone": ADMIN_PHONE, "password": "bad"})
    assert res.status_code == 401


def test_admin_routes_reject_customers(client):
    headers = _customer(client)
    for path in ("/api/v1/admin/stats", "/api/v1/admin/products", "/api/v1/admin/settings"):
        assert client.get(path, headers=headers).status_code == 403
        assert client.get(path).status_code == 401


def test_categories_crud_and_home(client, admin):
    res = client.post(
        "/api/v1/admin/categories",
        headers=admin,
        json={"slug": "roses", "name_ar": "ورود", "image": "/api/v1/media/c.jpg", "sort_order": 1},
    )
    assert res.status_code == 200
    cat = res.json()
    assert cat["name_en"] == "ورود"

    dup = client.post(
        "/api/v1/admin/categories", headers=admin, json={"slug": "roses", "name_ar": "x"}
    )
    assert dup.status_code == 400

    home = client.get("/api/v1/home").json()
    assert [c["slug"] for c in home["categories"]] == ["roses"]

    client.patch(f"/api/v1/admin/categories/{cat['id']}", headers=admin, json={"is_active": False})
    assert client.get("/api/v1/home").json()["categories"] == []

    product = _product(client, admin, category_id=cat["id"])
    listed = client.get("/api/v1/admin/categories", headers=admin).json()
    assert listed[0]["product_count"] == 1

    assert client.delete(f"/api/v1/admin/categories/{cat['id']}", headers=admin).status_code == 200
    detail = client.get(f"/api/v1/admin/products/{product['id']}", headers=admin).json()
    assert detail["category_id"] is None


def test_banners_crud_shown_in_home(client, admin):
    res = client.post(
        "/api/v1/admin/banners",
        headers=admin,
        json={"image": "/api/v1/media/banner.jpg", "link": "  /special-gift ", "title_ar": "عرض"},
    )
    banner = res.json()
    assert banner["link"] == "/special-gift"
    assert client.get("/api/v1/home").json()["banners"][0]["image"] == "/api/v1/media/banner.jpg"

    client.patch(f"/api/v1/admin/banners/{banner['id']}", headers=admin, json={"link": ""})
    assert client.get("/api/v1/home").json()["banners"][0]["link"] is None

    client.delete(f"/api/v1/admin/banners/{banner['id']}", headers=admin)
    assert client.get("/api/v1/home").json()["banners"] == []


def test_product_crud(client, admin):
    p = _product(client, admin)
    assert p["cover_image"] == "/api/v1/media/a.jpg"
    assert p["images"] == ["/api/v1/media/a.jpg", "/api/v1/media/b.jpg"]
    assert p["care_steps_ar"] == ["خطوة 1", "خطوة 2"]
    assert p["title_en"] == "باقة"

    public = client.get(f"/api/v1/products/{p['id']}").json()
    assert public["images"] == ["/api/v1/media/a.jpg", "/api/v1/media/b.jpg"]
    assert public["badges"][0]["label"] == "product_badge_natural"

    upd = client.patch(
        f"/api/v1/admin/products/{p['id']}",
        headers=admin,
        json={"price": 70000, "images": ["/api/v1/media/b.jpg"], "status": "hidden"},
    ).json()
    assert upd["price"] == 70000
    assert upd["cover_image"] == "/api/v1/media/b.jpg"
    assert client.get(f"/api/v1/products/{p['id']}").status_code == 404

    assert client.post(
        "/api/v1/admin/products", headers=admin, json={"sku": "P-1", "title_ar": "x", "price": 1}
    ).status_code == 400
    assert client.post(
        "/api/v1/admin/products",
        headers=admin,
        json={"sku": "P-9", "title_ar": "x", "price": 1, "category_id": 999},
    ).status_code == 400

    search = client.get("/api/v1/admin/products", headers=admin, params={"q": "P-1"}).json()
    assert search["total"] == 1


def test_delete_product_keeps_order_history(client, admin):
    p = _product(client, admin)
    customer = _customer(client)
    client.post("/api/v1/cart/items", headers=customer, json={"product_id": p["id"], "qty": 1})
    client.put(f"/api/v1/favorites/{p['id']}", headers=customer)
    order = client.post(
        "/api/v1/orders",
        headers=customer,
        json={"recipient_name": "Ali", "recipient_phone": "07701112233", "governorate": "gov_baghdad"},
    ).json()
    client.post("/api/v1/cart/items", headers=customer, json={"product_id": p["id"], "qty": 1})

    assert client.delete(f"/api/v1/admin/products/{p['id']}", headers=admin).status_code == 200
    assert client.get("/api/v1/cart", headers=customer).json()["items"] == []
    assert client.get("/api/v1/favorites", headers=customer).json()["total"] == 0
    kept = client.get(f"/api/v1/orders/{order['id']}", headers=customer).json()
    assert kept["items"][0]["title_ar"] == "باقة"


def test_latest_and_popular_ranking(client, admin):
    a = _product(client, admin, sku="A")
    b = _product(client, admin, sku="B")
    c = _product(client, admin, sku="C")

    # Latest = newest first.
    latest = [p["id"] for p in client.get("/api/v1/home").json()["latest"]]
    assert latest[:3] == [c["id"], b["id"], a["id"]]

    # Popular = real sales (x2) + favorites.
    buyer = _customer(client, "07722222222")
    client.post("/api/v1/cart/items", headers=buyer, json={"product_id": a["id"], "qty": 3})
    client.post(
        "/api/v1/orders",
        headers=buyer,
        json={"recipient_name": "Ali", "recipient_phone": "07701112233", "governorate": "gov_baghdad"},
    )
    client.put(f"/api/v1/favorites/{b['id']}", headers=buyer)
    bust_public_cache()  # guest home is cached for 30s
    popular = [p["id"] for p in client.get("/api/v1/home").json()["popular"]]
    assert popular == [a["id"], b["id"]]

    # A manual pin goes first.
    client.patch(f"/api/v1/admin/products/{c['id']}", headers=admin, json={"is_popular": True})
    client.patch(f"/api/v1/admin/products/{a['id']}", headers=admin, json={"is_latest": True})
    home = client.get("/api/v1/home").json()
    assert [p["id"] for p in home["popular"]][0] == c["id"]
    assert [p["id"] for p in home["latest"]][0] == a["id"]

    stats = {
        p["id"]: p for p in client.get("/api/v1/admin/products", headers=admin).json()["items"]
    }
    assert stats[a["id"]]["sold"] == 3
    assert stats[b["id"]]["favorites"] == 1
    sorted_popular = client.get(
        "/api/v1/products", params={"sort": "popular"}
    ).json()["items"]
    assert sorted_popular[0]["id"] == c["id"]


def test_options_crud(client, admin):
    for kind in ("gift-cards", "wraps", "addons"):
        res = client.post(
            f"/api/v1/admin/options/{kind}",
            headers=admin,
            json={"code": f"{kind}-1", "title_ar": "خيار", "price": 1000, "image": "/x.jpg", "category": "candles"},
        )
        assert res.status_code == 200, res.text
        opt = res.json()
        public = client.get(f"/api/v1/{kind}").json()
        assert public[0]["code"] == f"{kind}-1"
        client.patch(f"/api/v1/admin/options/{kind}/{opt['id']}", headers=admin, json={"is_active": False})
        assert client.get(f"/api/v1/{kind}").json() == []
        assert client.delete(f"/api/v1/admin/options/{kind}/{opt['id']}", headers=admin).status_code == 200
    assert client.get("/api/v1/admin/options/nope", headers=admin).status_code == 404


def test_orders_status_notifies_customer(client, admin):
    p = _product(client, admin)
    customer = _customer(client)
    client.post("/api/v1/cart/items", headers=customer, json={"product_id": p["id"], "qty": 2})
    order = client.post(
        "/api/v1/orders",
        headers=customer,
        json={"recipient_name": "Ali", "recipient_phone": "07701112233", "governorate": "gov_baghdad"},
    ).json()

    listing = client.get("/api/v1/admin/orders", headers=admin, params={"status": "pending"}).json()
    assert listing["total"] == 1
    assert listing["items"][0]["items_count"] == 2
    found = client.get("/api/v1/admin/orders", headers=admin, params={"q": order["code"]}).json()
    assert found["total"] == 1

    detail = client.patch(
        f"/api/v1/admin/orders/{order['id']}/status", headers=admin, json={"status": "shipping"}
    ).json()
    assert detail["status"] == "shipping"
    assert detail["customer"]["phone"] == "07711111111"
    assert client.get(f"/api/v1/orders/{order['id']}", headers=customer).json()["status"] == "shipping"
    titles = [n["title_ar"] for n in client.get("/api/v1/notifications", headers=customer).json()["items"]]
    assert "طلبك في الطريق" in titles

    stats = client.get("/api/v1/admin/stats", headers=admin).json()
    assert stats["orders_total"] == 1
    assert stats["revenue_total"] == order["total"]
    assert len(stats["series"]) == 14
    assert stats["series"][-1]["orders"] == 1


def test_users_management(client, admin):
    _customer(client)
    users = client.get("/api/v1/admin/users", headers=admin, params={"role": "customer"}).json()
    assert users["total"] == 1
    uid = users["items"][0]["id"]

    res = client.patch(f"/api/v1/admin/users/{uid}", headers=admin, json={"is_active": False})
    assert res.json()["is_active"] is False
    login = client.post("/api/v1/auth/login", json={"phone": "07711111111", "password": "secret12"})
    assert login.status_code == 401

    me = client.get("/api/v1/admin/me", headers=admin).json()
    lock = client.patch(f"/api/v1/admin/users/{me['id']}", headers=admin, json={"is_admin": False})
    assert lock.status_code == 400

    new_admin = client.post(
        "/api/v1/admin/admins",
        headers=admin,
        json={"phone": "07733333333", "password": "pass1234", "name": "Second"},
    )
    assert new_admin.status_code == 200
    assert client.post(
        "/api/v1/admin/login", json={"phone": "07733333333", "password": "pass1234"}
    ).status_code == 200


def test_broadcast_and_targeted_notifications(client, admin):
    c1 = _customer(client, "07744444444")
    c2 = _customer(client, "07755555555")
    client.patch("/api/v1/auth/me", headers=c2, json={"notifications_enabled": False})

    res = client.post(
        "/api/v1/admin/notifications",
        headers=admin,
        json={"title_ar": "خصم 20%", "body_ar": "لفترة محدودة", "link": "/special-gift"},
    ).json()
    assert res["recipients"] == 2  # admin + c1 (c2 disabled notifications)
    assert client.get("/api/v1/notifications", headers=c1).json()["items"][0]["title_ar"] == "خصم 20%"
    assert client.get("/api/v1/notifications", headers=c2).json()["total"] == 0

    direct = client.post(
        "/api/v1/admin/notifications",
        headers=admin,
        json={"title_ar": "لك فقط", "phone": "07755555555"},
    ).json()
    assert direct["recipients"] == 1
    assert client.get("/api/v1/notifications", headers=c2).json()["total"] == 1

    history = client.get("/api/v1/admin/notifications", headers=admin).json()
    assert history["total"] == 2
    client.delete(f"/api/v1/admin/notifications/{res['key']}", headers=admin)
    assert client.get("/api/v1/notifications", headers=c1).json()["total"] == 0
    assert client.post(
        "/api/v1/admin/notifications", headers=admin, json={"title_ar": "x", "phone": "07799999999"}
    ).status_code == 404


def test_faq_and_privacy_crud(client, admin):
    cat = client.post(
        "/api/v1/admin/faq/categories", headers=admin, json={"slug": "orders", "title_ar": "الطلبات"}
    ).json()
    item = client.post(
        "/api/v1/admin/faq/items",
        headers=admin,
        json={"category_id": cat["id"], "question_ar": "سؤال؟", "answer_ar": "جواب"},
    ).json()
    public = client.get("/api/v1/faq").json()["items"]
    assert public[0]["items"][0]["question_ar"] == "سؤال؟"
    assert public[0]["items"][0]["answer_en"] == "جواب"

    client.patch(f"/api/v1/admin/faq/items/{item['id']}", headers=admin, json={"answer_ar": "جواب جديد"})
    assert client.get("/api/v1/faq").json()["items"][0]["items"][0]["answer_ar"] == "جواب جديد"
    client.delete(f"/api/v1/admin/faq/categories/{cat['id']}", headers=admin)
    assert client.get("/api/v1/faq").json()["items"] == []

    sec = client.post(
        "/api/v1/admin/privacy", headers=admin, json={"slug": "intro", "title_ar": "مقدمة", "body_ar": "نص"}
    ).json()
    client.patch(f"/api/v1/admin/privacy/{sec['id']}", headers=admin, json={"body_ar": "نص محدث"})
    assert client.get("/api/v1/privacy").json()["items"][0]["body_ar"] == "نص محدث"
    client.delete(f"/api/v1/admin/privacy/{sec['id']}", headers=admin)
    assert client.get("/api/v1/privacy").json()["items"] == []


def test_support_tickets_reply(client, admin):
    customer = _customer(client)
    client.post(
        "/api/v1/support/tickets",
        headers=customer,
        json={"subject": "تأخير", "message": "طلبي متأخر جداً"},
    )
    client.post("/api/v1/support/tickets", json={"subject": "زائر", "message": "سؤال من زائر"})
    tickets = client.get("/api/v1/admin/support/tickets", headers=admin).json()
    assert tickets["total"] == 2
    member = next(t for t in tickets["items"] if t["user_id"])
    guest = next(t for t in tickets["items"] if not t["user_id"])

    res = client.patch(
        f"/api/v1/admin/support/tickets/{member['id']}", headers=admin, json={"reply": "سيصل خلال ساعة"}
    ).json()
    assert res["status"] == "in_progress"
    notes = client.get("/api/v1/notifications", headers=customer).json()["items"]
    assert any(n["body_ar"] == "سيصل خلال ساعة" for n in notes)

    assert client.patch(
        f"/api/v1/admin/support/tickets/{guest['id']}", headers=admin, json={"reply": "x"}
    ).status_code == 400
    closed = client.patch(
        f"/api/v1/admin/support/tickets/{guest['id']}", headers=admin, json={"status": "closed"}
    ).json()
    assert closed["status"] == "closed"
    open_only = client.get(
        "/api/v1/admin/support/tickets", headers=admin, params={"status": "closed"}
    ).json()
    assert open_only["total"] == 1


def test_settings_drive_public_endpoints(client, admin):
    res = client.put(
        "/api/v1/admin/settings",
        headers=admin,
        json={
            "values": {
                "support.phone": "+9647801234567",
                "share.url": "https://example.com/app",
                "pricing.delivery_fee": "7000",
                "pricing.free_delivery_threshold": "200000",
            }
        },
    )
    assert res.status_code == 200
    assert client.get("/api/v1/support/contact").json()["phone"] == "+9647801234567"
    assert client.get("/api/v1/app/share").json()["url"] == "https://example.com/app"
    lookups = client.get("/api/v1/lookups").json()
    assert lookups["delivery_fee"] == 7000
    assert lookups["free_delivery_threshold"] == 200000

    p = _product(client, admin, price=120000)
    customer = _customer(client)
    cart = client.post(
        "/api/v1/cart/items", headers=customer, json={"product_id": p["id"], "qty": 1}
    ).json()
    assert cart["pricing"]["delivery_price"] == 7000

    bad = client.put("/api/v1/admin/settings", headers=admin, json={"values": {"pricing.delivery_fee": "abc"}})
    assert bad.status_code == 400
    unknown = client.put("/api/v1/admin/settings", headers=admin, json={"values": {"x": "1"}})
    assert unknown.status_code == 400


def test_upload_requires_admin(client, admin):
    customer = _customer(client)
    files = {"file": ("a.png", b"\x89PNG\r\n\x1a\nfake", "image/png")}
    assert client.post("/api/v1/uploads/image", headers=customer, files=files).status_code == 403
    res = client.post("/api/v1/uploads/image", headers=admin, files=files)
    assert res.status_code == 200
    url = res.json()["url"]
    assert client.get(url).status_code == 200
    db = client.session_factory()
    assert db.scalars(select(User).where(User.phone == ADMIN_PHONE)).first().is_admin
    db.close()
