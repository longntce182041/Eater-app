from typing import List
from app.domain.models.meal import Meal
from app.domain.models.health_metrics import HealthMetrics


def summarize_meal_plan_nutrition(meals: List[Meal]) -> dict:
    """Aggregate calories, macros, and micronutrients for a meal plan."""
    raise NotImplementedError


def is_plan_within_targets(
    health_metrics: HealthMetrics,
    summary: dict,
) -> bool:
    """Check if a plan respects calorie and macro targets."""
    raise NotImplementedError