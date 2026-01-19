"""
Application configuration settings.
"""
from typing import List

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""

    # Application
    PROJECT_NAME: str = "AI Meal Planning Service"
    VERSION: str = "1.0.0"
    DEBUG: bool = False

    # API
    API_V1_PREFIX: str = "/api/v1"
    ALLOWED_ORIGINS: List[str] = ["*"]

    # Database
    DATABASE_URL: str = "postgresql+asyncpg://user:password@localhost:5432/meal_planner"

    # Security
    SECRET_KEY: str = "your-secret-key-change-in-production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30

    # AI Configuration
    DEFAULT_CALORIE_TARGET: int = 2000
    MEAL_VARIETY_THRESHOLD: float = 0.7
    NUTRITION_TOLERANCE_PERCENT: float = 0.1

    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
