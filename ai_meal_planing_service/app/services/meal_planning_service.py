from typing import List

from app.domain.models.user_profile import UserProfile
from app.domain.models.dietary_preferences import DietaryPreferences
from app.domain.models.meal_plan import MealPlan
from app.domain.models.meal import Meal
from app.domain.models.health_metrics import HealthMetrics
from app.infrastructure.repositories.base import (
    UserRepository,
    RecipeRepository,
    MealPlanRepository,
)
from app.services.ai_core.nutrition.bmr_tdee_calculator import build_health_metrics
from app.services.ai_core.rule_engine.rules_engine import RuleEngine
from app.services.ai_core.meal_planning.meal_plan_generator import MealPlanGenerator
from app.services.ai_core.meal_planning.meal_plan_optimizer import MealPlanOptimizer


class MealPlanningService:
    """High-level orchestration of the AI meal planning workflow."""

    def __init__(
        self,
        user_repo: UserRepository,
        recipe_repo: RecipeRepository,
        meal_plan_repo: MealPlanRepository,
        rule_engine: RuleEngine,
        generator: MealPlanGenerator,
        optimizer: MealPlanOptimizer,
    ) -> None:
        self.user_repo = user_repo
        self.recipe_repo = recipe_repo
        self.meal_plan_repo = meal_plan_repo
        self.rule_engine = rule_engine
        self.generator = generator
        self.optimizer = optimizer

    async def generate_and_optimize_plan(
        self,
        user_id: str,
        days: int = 7,
    ) -> MealPlan:
        """End-to-end use-case: fetch data, generate, optimize, persist."""
        raise NotImplementedError