from pydantic import BaseModel


class UserProfile(BaseModel):
    user_id: str
    age: int
    gender: str  # "male" | "female" | "other"
    height_cm: float
    weight_kg: float
    goal_weight_kg: float
    health_goals: str  # e.g. "weight loss", "muscle gain", "maintenance"
    activity_level: str  # "sedentary", "light", "moderate", "active"