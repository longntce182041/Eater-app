from fastapi import FastAPI

from app.api.v1.api import api_router
from app.core.config import settings

def create_app() -> FastAPI:
    app = FastAPI(
        title="AI Meal Planning Service",
        version="1.0.0",
    )

    app.include_router(api_router, prefix=settings.API_V1_PREFIX)

    return app


app = create_app()