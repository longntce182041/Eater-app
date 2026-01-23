from fastapi import APIRouter

from app.api.v1.endpoints import health, meal_planning

api_router = APIRouter()
api_router.include_router(health.router, prefix="/health", tags=["health"])
api_router.include_router(meal_planning.router, prefix="/meal-planning", tags=["meal-planning"])