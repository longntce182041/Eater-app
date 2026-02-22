from pydantic import BaseModel, Field
from typing import Optional, List


class UserProfileRequest(BaseModel):
    """Request schema for user profile analysis"""
    user_id: str = Field(..., description="User ID from backend")
    age: int = Field(..., ge=1, le=120, description="User age in years")
    gender: str = Field(..., description="Gender: male, female, or other")
    height_cm: float = Field(..., gt=0, description="Height in centimeters")
    weight_kg: float = Field(..., gt=0, description="Current weight in kilograms")
    goal_weight_kg: float = Field(..., gt=0, description="Target/goal weight in kilograms")
    health_goals: str = Field(..., description="Primary health goal (e.g., weight_loss, muscle_gain, maintenance)")
    activity_level: str = Field(..., description="Activity level: sedentary, light, moderate, active, very_active")


class HealthMetricsResponse(BaseModel):
    """Health metrics calculated by AI"""
    bmr: float = Field(..., description="Basal Metabolic Rate in calories/day")
    tdee: float = Field(..., description="Total Daily Energy Expenditure in calories/day")
    target_calories: float = Field(..., description="Target daily calorie intake")


class AnalysisSummary(BaseModel):
    """Human-readable explanations"""
    bmr_explanation: str
    tdee_explanation: str
    target_explanation: str


class UserProfileAnalysisResponse(BaseModel):
    """Complete user profile analysis response"""
    user_id: str = Field(..., description="User ID")
    health_metrics: HealthMetricsResponse = Field(..., description="Calculated health metrics")
    bmi: float = Field(..., description="Body Mass Index")
    bmi_category: str = Field(..., description="BMI category: underweight, normal_weight, overweight, obese")
    primary_health_goal: str = Field(..., description="Primary health goal")
    activity_level: str = Field(..., description="Activity level")
    analysis_summary: AnalysisSummary = Field(..., description="Human-readable explanations")
    source: str = Field(default="AI", description="Source of analysis: AI or Nutritionist")
