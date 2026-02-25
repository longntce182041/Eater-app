# noinspection PyInterpreter
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.api import api_router
from app.core.config import settings

def create_app() -> FastAPI:
    app = FastAPI(
        title="AI Meal Planning Service",
        version="1.0.0",
        description="AI-powered meal planning and nutrition optimization service",
    )

    # Configure CORS
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],  # In production, specify allowed origins
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # Include API routes
    app.include_router(api_router, prefix=settings.API_V1_PREFIX)

    @app.get("/")
    async def root():
        return {
            "message": "AI Meal Planning Service",
            "version": "1.0.0",
            "status": "running",
        }

    return app


app = create_app()