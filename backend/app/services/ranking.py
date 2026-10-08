"""Latest / most-popular product ranking.

- Popularity = (units sold in non-cancelled orders × 2) + times added to favorites.
- Latest = newest products by creation date.
- `Product.is_popular` / `Product.is_latest` are manual pins from the dashboard:
  pinned products always come first in their section.
"""

from __future__ import annotations

from sqlalchemy import Select, func, select
from sqlalchemy.orm import Session

from app.models import Favorite, Order, OrderItem, Product

SALES_WEIGHT = 2
FAVORITE_WEIGHT = 1


def sales_subquery():
    return (
        select(
            OrderItem.product_id.label("product_id"),
            func.coalesce(func.sum(OrderItem.qty), 0).label("sold"),
        )
        .join(Order, Order.id == OrderItem.order_id)
        .where(OrderItem.product_id.is_not(None), Order.status != "cancelled")
        .group_by(OrderItem.product_id)
        .subquery()
    )


def favorites_subquery():
    return (
        select(
            Favorite.product_id.label("product_id"),
            func.count(Favorite.id).label("favs"),
        )
        .group_by(Favorite.product_id)
        .subquery()
    )


def with_popularity(stmt: Select) -> tuple[Select, object, object, object]:
    """Outer-joins sales & favorites counts onto a `select(Product)` statement.

    Returns (stmt, sold_col, favs_col, score_col).
    """
    sales = sales_subquery()
    favs = favorites_subquery()
    sold_col = func.coalesce(sales.c.sold, 0)
    favs_col = func.coalesce(favs.c.favs, 0)
    score_col = sold_col * SALES_WEIGHT + favs_col * FAVORITE_WEIGHT
    stmt = stmt.outerjoin(sales, sales.c.product_id == Product.id).outerjoin(
        favs, favs.c.product_id == Product.id
    )
    return stmt, sold_col, favs_col, score_col


def popular_products(db: Session, limit: int = 12) -> list[Product]:
    stmt, _sold, _favs, score = with_popularity(
        select(Product).where(Product.status == "active")
    )
    rows = db.scalars(
        stmt.where((Product.is_popular.is_(True)) | (score > 0))
        .order_by(Product.is_popular.desc(), score.desc(), Product.id.desc())
        .limit(limit)
    ).all()
    if rows:
        return list(rows)
    # A new store with no sales/favorites yet: best rated first.
    return list(
        db.scalars(
            select(Product)
            .where(Product.status == "active")
            .order_by(Product.rating.desc(), Product.id.desc())
            .limit(limit)
        ).all()
    )


def latest_products(db: Session, limit: int = 12) -> list[Product]:
    return list(
        db.scalars(
            select(Product)
            .where(Product.status == "active")
            .order_by(Product.is_latest.desc(), Product.created_at.desc(), Product.id.desc())
            .limit(limit)
        ).all()
    )


def product_stats(db: Session, product_ids: list[int]) -> dict[int, dict[str, int]]:
    """{product_id: {"sold": n, "favorites": n, "score": n}}"""
    if not product_ids:
        return {}
    stmt, sold_col, favs_col, _score = with_popularity(
        select(Product.id).select_from(Product)
    )
    rows = db.execute(
        stmt.add_columns(sold_col, favs_col).where(Product.id.in_(product_ids))
    ).all()
    return {
        pid: {
            "sold": int(s or 0),
            "favorites": int(f or 0),
            "score": int(s or 0) * SALES_WEIGHT + int(f or 0) * FAVORITE_WEIGHT,
        }
        for pid, s, f in rows
    }
