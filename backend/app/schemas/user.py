"""
User schemas for request/response validation.
"""
from typing import Any, Dict, List, Optional

from pydantic import BaseModel, Field

from app.core.constants import ActivityLevel, DietType, Gender, HealthGoal


class UserProfile(BaseModel):
    """User profile data for analysis."""

    user_id: str = Field(..., description="Unique user identifier")
    age: int = Field(..., ge=13, le=120, description="User age in years")
    gender: Gender = Field(..., description="User gender")
    weight_kg: float = Field(..., gt=20, lt=500, description="Weight in kg")
    height_cm: float = Field(..., gt=50, lt=300, description="Height in cm")
    activity_level: ActivityLevel = Field(..., description="Physical activity level")
    health_goal: HealthGoal = Field(
        default=HealthGoal.MAINTENANCE,
        description="Health/fitness goal",
    )
    diet_type: Optional[DietType] = Field(
        default=None,
        description="Preferred diet type",
    )
    allergies: Optional[List[str]] = Field(
        default=None,
        description="Food allergies",
    )
    intolerances: Optional[List[str]] = Field(
        default=None,
        description="Food intolerances",
    )
    medical_conditions: Optional[List[str]] = Field(
        default=None,
        description="Relevant medical conditions",
    )

    class Config:
        json_schema_extra = {
            "example": {
                "user_id": "user_123",
                "age": 30,
                "gender": "male",
                "weight_kg": 75.0,
                "height_cm": 175.0,
                "activity_level": "moderately_active",
                "health_goal": "weight_loss",
                "diet_type": "mediterranean",
                "allergies": ["peanuts"],
                "intolerances": ["lactose"],
                "medical_conditions": None,
            }
        }


class UserProfileAnalysis(BaseModel):
    """Response schema for user profile analysis."""

    user_id: str
    profile: UserProfile
    analysis: Dict[str, Any]
    metabolism: Dict[str, Any]
    target_calories: int
    recommended_diet: DietType


class UserCreate(BaseModel):
    """Schema for creating a new user."""

    email: str = Field(..., description="User email")
    password: str = Field(..., min_length=8, description="User password")
    username: Optional[str] = Field(None, description="Username")


class UserResponse(BaseModel):
    """Schema for user response."""

    id: str
    email: str
    username: Optional[str]
    is_active: bool = True

    class Config:
        from_attributes = True
