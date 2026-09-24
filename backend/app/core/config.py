"""Central app configuration. Values come from backend/.env (see .env.example).

Loads .env from the `backend/` directory. Environment variables always win
over the .env file, which lets test_api.py override DATABASE_URL.
"""

from pathlib import Path

from pydantic_settings import BaseSettings, SettingsConfigDict

BACKEND_DIR = Path(__file__).resolve().parent.parent.parent


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=BACKEND_DIR / ".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    app_name: str = "Fashion Store API"
    app_version: str = "1.0.0"
    debug: bool = False

    # Comma-separated list of allowed CORS origins, e.g.
    # CORS_ORIGINS=http://localhost:8080,https://shop.example.com
    cors_origins: str = "*"

    database_url: str = "sqlite:///./fashion_store.db"

    secret_key: str = "fashion-store-secret-2026-change-me"
    algorithm: str = "HS256"
    token_expire_hours: int = 24


settings = Settings()


def parse_cors_origins(raw: str) -> list[str]:
    return [origin.strip() for origin in raw.split(",") if origin.strip()]