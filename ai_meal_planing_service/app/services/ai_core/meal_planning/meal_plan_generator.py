from typing import List
from app.domain.models.meal import Meal
from app.domain.models.meal_plan import MealPlan
from app.domain.models.user_profile import UserProfile
from app.domain.models.dietary_preferences import DietaryPreferences
from app.domain.models.health_metrics import HealthMetrics


class MealPlanGenerator:
    async def generate_meal_plan(
        self,
        user: UserProfile,
        preferences: DietaryPreferences,
        health_metrics: HealthMetrics,
        candidate_meals: List[Meal],
        days: int = 7,
    ) -> MealPlan:
        """Generate a rule-based meal plan for the specified number of days."""
        raise NotImplementedError