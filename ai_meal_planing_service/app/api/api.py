from fastapi import APIRouter

from app.api.endpoints import health, meal_planning, user_analysis, meal_plan_pipeline

api_router = APIRouter()
api_router.include_router(health.router, prefix="/health", tags=["health"])
api_router.include_router(meal_planning.router, prefix="/meal-planning", tags=["meal-planning"])
api_router.include_router(user_analysis.router, prefix="/user-profile", tags=["user-analysis"])
api_router.include_router(meal_plan_pipeline.router, prefix="/pipeline", tags=["AI Pipeline"])