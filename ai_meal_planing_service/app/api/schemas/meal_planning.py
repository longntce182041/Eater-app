from pydantic import BaseModel
from typing import Optional


class GenerateMealPlanRequest(BaseModel):
    user_id: str
    days: int = 7
    use_ml: bool = False  # whether to use optional ML/LLM module


class MealPlanResponse(BaseModel):
    # Simplified schema mirroring domain MealPlan
    user_id: str
    days: int
    # TODO: add meals and nutrition summary
    # meals: List[...]