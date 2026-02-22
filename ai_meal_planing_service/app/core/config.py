from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    API_V1_PREFIX: str = "/api"  # Changed from /api/v1 to match actual deployment
    ENV: str = "development"
    DEBUG: bool = True

    # Backend integration
    BACKEND_BASE_URL: str = "http://localhost:4000"
    BACKEND_TIMEOUT_SECONDS: int = 10

    class Config:
        env_file = ".env"


settings = Settings()