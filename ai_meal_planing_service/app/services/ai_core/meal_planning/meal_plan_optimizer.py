from app.domain.models.meal_plan import MealPlan
from app.domain.models.health_metrics import HealthMetrics


class MealPlanOptimizer:
    async def optimize(
        self,
        meal_plan: MealPlan,
        health_metrics: HealthMetrics,
    ) -> MealPlan:
        """Apply optimization heuristics to improve nutritional balance."""
        raise NotImplementedError