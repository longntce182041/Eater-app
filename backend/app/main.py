"""
AI Meal Planning Service - FastAPI Application Entry Point
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.endpoints import health, users, meal_plans, nutrition
from app.core.config import settings

app = FastAPI(
    title=settings.PROJECT_NAME,
    description="AI-powered meal planning service with rule-based algorithms",
    version=settings.VERSION,
    openapi_url=f"{settings.API_V1_PREFIX}/openapi.json",
    docs_url="/docs",
    redoc_url="/redoc",
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(health.router, tags=["Health"])
app.include_router(
    users.router,
    prefix=f"{settings.API_V1_PREFIX}/users",
    tags=["Users"],
)
app.include_router(
    meal_plans.router,
    prefix=f"{settings.API_V1_PREFIX}/meal-plans",
    tags=["Meal Plans"],
)
app.include_router(
    nutrition.router,
    prefix=f"{settings.API_V1_PREFIX}/nutrition",
    tags=["Nutrition"],
)


@app.on_event("startup")
async def startup_event():
    """Application startup event handler."""
    # TODO: Initialize database connections, cache, etc.
    pass


@app.on_event("shutdown")
async def shutdown_event():
    """Application shutdown event handler."""
    # TODO: Clean up database connections, etc.
    pass
