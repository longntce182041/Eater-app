from pydantic import BaseModel, Field
from typing import Optional, Dict, Any


class GenerateMealPlanRequest(BaseModel):
    user_id: str = Field(..., description="User ID from the backend")
    days: int = Field(default=7, ge=1, le=30, description="Number of days for the meal plan")
    use_ml: bool = Field(default=False, description="Whether to use ML/LLM features")
    user_data: Optional[Dict[str, Any]] = Field(default=None, description="Optional user data including profile, preferences, and health metrics")


class MealPlanResponse(BaseModel):
    user_id: str = Field(..., description="User ID")
    days: int = Field(..., description="Number of days in the meal plan")
    status: str = Field(default="generated", description="Status of the meal plan generation")
    message: str = Field(..., description="Success message")
    created_at: str = Field(..., description="Timestamp when the meal plan was created")
    # TODO: add meals and nutrition summary
    # meals: List[MealDetail] = []
    # nutrition_summary: Optional[NutritionSummary] = None