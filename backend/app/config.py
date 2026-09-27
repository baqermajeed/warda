from datetime import datetime, timezone

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    app_name: str = "Warda"
    app_env: str = "development"
    secret_key: str = "warda-dev-change-me-please"
    database_url: str = "sqlite:///./warda.db"
    redis_url: str = ""
    cors_origins: str = "*"
    trusted_hosts: str = "localhost,127.0.0.1,testserver"
    access_token_minutes: int = 15
    refresh_token_days: int = 30
    otp_ttl_seconds: int = 300
    otp_max_attempts: int = 5
    otp_rate_limit_per_minute: int = 5
    upload_dir: str = "./uploads"
    upload_max_bytes: int = 3 * 1024 * 1024
    free_delivery_threshold: int = 100_000
    delivery_fee: int = 5_000
    otp_dev_return_code: bool = True

    @property
    def origins(self) -> list[str]:
        if self.cors_origins.strip() == "*":
            return ["*"]
        return [o.strip() for o in self.cors_origins.split(",") if o.strip()]

    @property
    def hosts(self) -> list[str]:
        raw = [h.strip() for h in self.trusted_hosts.split(",") if h.strip()]
        # في التطوير اسمح بأي Host (هاتف حقيقي / LAN / محاكي).
        if self.is_dev or "*" in raw:
            return ["*"]
        return raw

    @property
    def is_sqlite(self) -> bool:
        return self.database_url.startswith("sqlite")

    @property
    def is_dev(self) -> bool:
        return self.app_env.lower() in {"development", "dev", "local", "test"}


settings = Settings()


def utcnow() -> datetime:
    return datetime.now(timezone.utc).replace(tzinfo=None)
