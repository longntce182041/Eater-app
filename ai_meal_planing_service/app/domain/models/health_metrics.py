from pydantic import BaseModel


class HealthMetrics(BaseModel):
    bmr: float
    tdee: float
    target_calories: float