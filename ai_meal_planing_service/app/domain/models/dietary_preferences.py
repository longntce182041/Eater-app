from pydantic import BaseModel
from typing import List


class DietaryPreferences(BaseModel):
   
    dietary_style: str  # e.g. "vegan", "keto", "balanced"
    allergies: List[str] = []
    dislikesIngredients: List[str] = []
    activity_level: str  # e.g. "sedentary", "active", "very active"
    health_goals: List[str] = []  # e.g. "weight loss",
    cooking_skill_level: str  # e.g. "beginner", "intermediate", "expert"
    avilable_cooking_time_per_meal: int  # in minutes
    daily_calorie_target: int
