"""
Meal Plan Generator Service

Generates and optimizes meal plans using rule-based AI algorithms.
"""
from datetime import date, timedelta
from typing import Dict, List, Optional
from uuid import uuid4

from app.core.constants import (
    MEAL_CALORIE_DISTRIBUTION,
    DietType,
    MealType,
)
from app.services.ai.nutrition_calculator import nutrition_calculator


class MealPlanGenerator:
    """Generates optimized meal plans using rule-based algorithms."""

    def generate_daily_plan(
        self,
        target_calories: int,
        diet_type: DietType,
        dietary_restrictions: List[str],
        preferences: Optional[Dict] = None,
        plan_date: Optional[date] = None,
    ) -> Dict:
        """
        Generate a daily meal plan.

        Args:
            target_calories: Daily calorie target
            diet_type: Type of diet
            dietary_restrictions: List of foods/ingredients to avoid
            preferences: User food preferences
            plan_date: Date for the meal plan

        Returns:
            Dictionary with daily meal plan
        """
        if plan_date is None:
            plan_date = date.today()

        # Calculate macros for the day
        daily_macros = nutrition_calculator.calculate_macros(
            target_calories=target_calories,
            diet_type=diet_type,
        )

        # Generate meals for each meal type
        meals = []
        for meal_type in [MealType.BREAKFAST, MealType.LUNCH, MealType.DINNER, MealType.SNACK]:
            meal_ratio = MEAL_CALORIE_DISTRIBUTION[meal_type]
            meal = self._generate_meal(
                meal_type=meal_type,
                calorie_target=int(target_calories * meal_ratio),
                diet_type=diet_type,
                restrictions=dietary_restrictions,
                preferences=preferences,
            )
            meals.append(meal)

        return {
            "id": str(uuid4()),
            "date": plan_date.isoformat(),
            "target_calories": target_calories,
            "diet_type": diet_type.value,
            "daily_macros": daily_macros,
            "meals": meals,
            "is_optimized": True,
        }

    def generate_weekly_plan(
        self,
        target_calories: int,
        diet_type: DietType,
        dietary_restrictions: List[str],
        preferences: Optional[Dict] = None,
        start_date: Optional[date] = None,
    ) -> Dict:
        """
        Generate a weekly meal plan with variety optimization.

        Args:
            target_calories: Daily calorie target
            diet_type: Type of diet
            dietary_restrictions: List of restrictions
            preferences: User preferences
            start_date: Week start date

        Returns:
            Dictionary with weekly meal plan
        """
        if start_date is None:
            start_date = date.today()

        daily_plans = []
        used_recipes = set()  # Track used recipes for variety

        for day_offset in range(7):
            plan_date = start_date + timedelta(days=day_offset)
            daily_plan = self.generate_daily_plan(
                target_calories=target_calories,
                diet_type=diet_type,
                dietary_restrictions=dietary_restrictions,
                preferences=preferences,
                plan_date=plan_date,
            )

            # Apply variety optimization
            daily_plan = self._optimize_variety(daily_plan, used_recipes)

            # Track used recipes
            for meal in daily_plan["meals"]:
                if meal.get("recipe_id"):
                    used_recipes.add(meal["recipe_id"])

            daily_plans.append(daily_plan)

        return {
            "id": str(uuid4()),
            "start_date": start_date.isoformat(),
            "end_date": (start_date + timedelta(days=6)).isoformat(),
            "target_calories": target_calories,
            "diet_type": diet_type.value,
            "daily_plans": daily_plans,
            "total_days": 7,
        }

    def _generate_meal(
        self,
        meal_type: MealType,
        calorie_target: int,
        diet_type: DietType,
        restrictions: List[str],
        preferences: Optional[Dict] = None,
    ) -> Dict:
        """
        Generate a single meal using rule-based selection.

        This is a placeholder that returns meal structure.
        In production, this would query a recipe database and apply
        matching algorithms.
        """
        # Calculate meal-specific macros
        meal_macros = nutrition_calculator.calculate_meal_nutrition(
            daily_macros=nutrition_calculator.calculate_macros(
                target_calories=calorie_target * 4,  # Approximate daily total
                diet_type=diet_type,
            ),
            meal_ratio=0.25,  # This meal's portion
        )

        return {
            "id": str(uuid4()),
            "meal_type": meal_type.value,
            "name": f"Placeholder {meal_type.value.title()}",
            "description": f"A healthy {meal_type.value} suitable for {diet_type.value} diet",
            "calorie_target": calorie_target,
            "estimated_calories": calorie_target,
            "macros": {
                "protein_g": meal_macros.get("protein_grams", 0),
                "carbs_g": meal_macros.get("carbohydrates_grams", 0),
                "fat_g": meal_macros.get("fat_grams", 0),
            },
            "recipe_id": None,  # Would be populated from recipe database
            "alternatives": [],  # Alternative meals user can swap to
        }

    def _optimize_variety(
        self,
        daily_plan: Dict,
        used_recipes: set,
    ) -> Dict:
        """
        Optimize meal plan for variety by avoiding recently used recipes.

        This is a placeholder for the variety optimization algorithm.
        In production, this would swap meals that were used recently.
        """
        # TODO: Implement variety optimization algorithm
        # - Track recipe usage across days
        # - Swap meals with alternatives if repeated
        # - Ensure diverse protein sources, vegetables, etc.
        return daily_plan

    def optimize_nutrition_balance(
        self,
        meal_plan: Dict,
        tolerance_percent: float = 0.1,
    ) -> Dict:
        """
        Optimize meal plan to better match nutritional targets.

        Args:
            meal_plan: The meal plan to optimize
            tolerance_percent: Acceptable deviation from targets

        Returns:
            Optimized meal plan
        """
        target_calories = meal_plan["target_calories"]
        current_total = sum(
            meal.get("estimated_calories", 0)
            for meal in meal_plan.get("meals", [])
        )

        # Check if within tolerance
        deviation = abs(current_total - target_calories) / target_calories

        if deviation <= tolerance_percent:
            meal_plan["optimization_status"] = "optimal"
        else:
            meal_plan["optimization_status"] = "needs_adjustment"
            meal_plan["calorie_deviation"] = round(deviation * 100, 1)

        return meal_plan


# Singleton instance
meal_plan_generator = MealPlanGenerator()
