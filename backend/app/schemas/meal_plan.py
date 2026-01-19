"""
Meal plan schemas for request/response validation.
"""
from datetime import date
from typing import Any, Dict, List, Optional

from pydantic import BaseModel, Field

from app.core.constants import DietType, MealType


class MealPlanRequest(BaseModel):
    """Request schema for meal plan generation."""

    user_id: str = Field(..., description="User identifier")
    target_calories: int = Field(
        ...,
        ge=1200,
        le=5000,
        description="Daily calorie target",
    )
    diet_type: DietType = Field(
        default=DietType.STANDARD,
        description="Diet type",
    )
    plan_type: str = Field(
        default="daily",
        pattern="^(daily|weekly)$",
        description="Plan type: daily or weekly",
    )
    start_date: Optional[date] = Field(
        default=None,
        description="Start date for the plan",
    )
    dietary_restrictions: Optional[List[str]] = Field(
        default=None,
        description="List of dietary restrictions",
    )
    preferences: Optional[Dict[str, Any]] = Field(
        default=None,
        description="Additional preferences",
    )

    class Config:
        json_schema_extra = {
            "example": {
                "user_id": "user_123",
                "target_calories": 2000,
                "diet_type": "mediterranean",
                "plan_type": "daily",
                "start_date": "2024-01-20",
                "dietary_restrictions": ["gluten", "dairy"],
                "preferences": {"prefer_quick_meals": True},
            }
        }


class MealSchema(BaseModel):
    """Schema for a single meal."""

    id: str
    meal_type: MealType
    name: str
    description: Optional[str] = None
    calorie_target: int
    estimated_calories: int
    macros: Dict[str, float]
    recipe_id: Optional[str] = None
    alternatives: List[str] = []


class DailyPlanSchema(BaseModel):
    """Schema for a daily meal plan."""

    id: str
    date: str
    target_calories: int
    diet_type: str
    daily_macros: Dict[str, Any]
    meals: List[Dict[str, Any]]
    is_optimized: bool = False


class MealPlanResponse(BaseModel):
    """Response schema for meal plan generation."""

    id: str
    plan_type: str
    data: Dict[str, Any]
    message: str

    class Config:
        json_schema_extra = {
            "example": {
                "id": "plan_abc123",
                "plan_type": "daily",
                "data": {
                    "date": "2024-01-20",
                    "target_calories": 2000,
                    "meals": [],
                },
                "message": "Meal plan generated successfully",
            }
        }
