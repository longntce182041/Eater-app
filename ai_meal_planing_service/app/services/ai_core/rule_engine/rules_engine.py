from typing import List
from app.domain.models.meal import Meal
from app.domain.models.dietary_preferences import DietaryPreferences
from .constraints import filter_meals_by_constraints


class RuleEngine:
    def apply(self, meals: List[Meal], preferences: DietaryPreferences) -> List[Meal]:
        """Main entry for rule-based filtering and meal selection."""
        return filter_meals_by_constraints(meals, preferences)