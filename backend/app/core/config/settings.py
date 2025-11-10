from functools import lru_cache
from typing import Literal

from pydantic import AnyHttpUrl, BaseSettings, Field, PostgresDsn, validator


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""

    environment: Literal["local", "staging", "production"] = "local"
    api_prefix: str = "/api/v1"
    secret_key: str = Field(..., min_length=32)  # TODO(security): Rotate secrets regularly.

    database_dsn: PostgresDsn = Field(..., alias="DATABASE_DSN")
    s3_endpoint_url: AnyHttpUrl = Field(..., alias="S3_ENDPOINT")
    s3_bucket_original: str = Field(..., alias="S3_BUCKET_ORIGINAL")
    s3_bucket_modified: str = Field(..., alias="S3_BUCKET_MODIFIED")

    aws_access_key_id: str = Field(default="", alias="AWS_ACCESS_KEY_ID")
    aws_secret_access_key: str = Field(default="", alias="AWS_SECRET_ACCESS_KEY")

    class Config:
        case_sensitive = True
        env_file = ".env"

    @validator("secret_key")
    def validate_secret_key(cls, value: str) -> str:
        if len(value) < 32:
            raise ValueError("Secret key must be at least 32 characters.")
        return value


@lru_cache
def get_settings() -> Settings:
    """Return cached application settings."""
    return Settings()
