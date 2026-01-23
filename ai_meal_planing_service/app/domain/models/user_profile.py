from pydantic import BaseModel


class UserProfile(BaseModel):
    user_id: str
    age: int
    gender: str  # "male" | "female" | "other"
    height_cm: float
    weight_kg: float
    activity_level: str  # "sedentary", "light", "moderate", "active"