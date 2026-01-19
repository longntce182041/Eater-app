"""
Nutrition schemas for request/response validation.
"""
from typing import Any, Dict, Optional

from pydantic import BaseModel, Field

from app.core.constants import DietType, Gender, HealthGoal


class NutritionCalculationRequest(BaseModel):
    """Request schema for nutrition calculation."""

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
    health_goal: Optional[HealthGoal] = Field(
        default=None,
        description="Health goal",
    )
    age: Optional[int] = Field(
        default=None,
        ge=13,
        le=120,
        description="Age for micronutrient calculations",
    )
    gender: Optional[Gender] = Field(
        default=None,
        description="Gender for micronutrient calculations",
    )

    class Config:
        json_schema_extra = {
            "example": {
                "target_calories": 2000,
                "diet_type": "standard",
                "health_goal": "maintenance",
                "age": 30,
                "gender": "male",
            }
        }


class MacroNutrients(BaseModel):
    """Macronutrient breakdown."""

    protein_grams: float
    protein_calories: float
    protein_percent: float
    carbohydrates_grams: float
    carbohydrates_calories: float
    carbohydrates_percent: float
    fat_grams: float
    fat_calories: float
    fat_percent: float
    total_calories: int


class MicroNutrients(BaseModel):
    """Micronutrient recommendations."""

    vitamin_a_mcg: float
    vitamin_c_mg: float
    vitamin_d_mcg: float
    vitamin_e_mg: float
    vitamin_k_mcg: float
    calcium_mg: float
    iron_mg: float
    magnesium_mg: float
    potassium_mg: float
    sodium_mg: float
    zinc_mg: float
    fiber_g: float


class NutritionResponse(BaseModel):
    """Response schema for nutrition calculation."""

    daily_calories: int
    diet_type: str
    macronutrients: Dict[str, Any]
    micronutrients: Dict[str, float]

    class Config:
        json_schema_extra = {
            "example": {
                "daily_calories": 2000,
                "diet_type": "standard",
                "macronutrients": {
                    "protein_grams": 125.0,
                    "carbohydrates_grams": 250.0,
                    "fat_grams": 55.6,
                },
                "micronutrients": {
                    "vitamin_a_mcg": 900,
                    "calcium_mg": 1000,
                },
            }
        }


class BMRCalculationRequest(BaseModel):
    """Request schema for BMR/TDEE calculation."""

    weight_kg: float = Field(..., gt=20, lt=500, description="Weight in kg")
    height_cm: float = Field(..., gt=50, lt=300, description="Height in cm")
    age: int = Field(..., ge=13, le=120, description="Age in years")
    gender: Gender = Field(..., description="Gender")

    class Config:
        json_schema_extra = {
            "example": {
                "weight_kg": 75.0,
                "height_cm": 175.0,
                "age": 30,
                "gender": "male",
            }
        }


class BMRResponse(BaseModel):
    """Response schema for BMR calculation."""

    bmr_harris_benedict: float
    bmr_mifflin_st_jeor: float
    bmr_used: float
