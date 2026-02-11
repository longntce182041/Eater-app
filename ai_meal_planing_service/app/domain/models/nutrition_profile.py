# File: d:\SP26\WDP\code base\Eater-app\ai_meal_planing_service\app\domain\models\nutrition_profile.py

from pydantic import BaseModel
from typing import Optional
from app.domain.value_objects.macro_split import MacroSplit
from app.domain.value_objects.micronutrient_profile import MicronutrientProfile


class NutritionProfile(BaseModel):
    """Complete nutrition profile for a user including all targets."""
    
    user_id: str
    
    # Daily targets
    target_calories: float
    target_macros: MacroSplit
    target_micronutrients: Optional[MicronutrientProfile] = None
    
    # Context
    dietary_style: str
    health_goal: str
    
    # Meal distribution
    meal_distribution: Optional[dict] = None
    
    class Config:
        json_schema_extra = {
            "example": {
                "user_id": "user123",
                "target_calories": 2000,
                "target_macros": {
                    "protein_g": 150,
                    "carbs_g": 200,
                    "fat_g": 67,
                    "protein_percent": 30,
                    "carbs_percent": 40,
                    "fat_percent": 30
                },
                "dietary_style": "balanced",
                "health_goal": "muscle_gain"
            }
        }