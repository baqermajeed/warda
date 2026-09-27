"""Initial schema placeholder — app also calls create_all on startup in development."""

from alembic import op
import sqlalchemy as sa

revision = "0001_initial"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Tables are managed via SQLAlchemy metadata.create_all in early development.
    # Generate a full autogenerate revision once schema stabilizes:
    #   alembic revision --autogenerate -m "sync"
    pass


def downgrade() -> None:
    pass
