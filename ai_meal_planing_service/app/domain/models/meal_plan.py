from pydantic import BaseModel
from typing import List
from .meal import Meal


class MealPlan(BaseModel):
    user_id: str
    days: int
    meals: List[Meal]