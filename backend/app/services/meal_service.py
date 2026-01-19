"""
Meal Service

Business logic for meal planning operations.
"""
from datetime import date
from typing import Dict, List, Optional

from app.core.constants import DietType
from app.schemas.meal_plan import MealPlanRequest, MealPlanResponse
from app.services.ai.meal_plan_generator import meal_plan_generator
from app.services.ai.nutrition_calculator import nutrition_calculator


class MealService:
    """Business logic for meal planning operations."""

    def generate_meal_plan(
        self,
        request: MealPlanRequest,
    ) -> MealPlanResponse:
        """
        Generate a meal plan based on user request.

        Args:
            request: Meal plan generation request

        Returns:
            Generated meal plan
        """
        if request.plan_type == "weekly":
            plan = meal_plan_generator.generate_weekly_plan(
                target_calories=request.target_calories,
                diet_type=request.diet_type,
                dietary_restrictions=request.dietary_restrictions or [],
                preferences=request.preferences,
                start_date=request.start_date,
            )
        else:
            plan = meal_plan_generator.generate_daily_plan(
                target_calories=request.target_calories,
                diet_type=request.diet_type,
                dietary_restrictions=request.dietary_restrictions or [],
                preferences=request.preferences,
                plan_date=request.start_date,
            )

        # Optimize the plan
        if request.plan_type == "daily":
            plan = meal_plan_generator.optimize_nutrition_balance(plan)

        return MealPlanResponse(
            id=plan["id"],
            plan_type=request.plan_type,
            data=plan,
            message="Meal plan generated successfully",
        )

    def calculate_nutrition_requirements(
        self,
        target_calories: int,
        diet_type: DietType,
        health_goal: Optional[str] = None,
    ) -> Dict:
        """
        Calculate complete nutrition requirements.

        Args:
            target_calories: Daily calorie target
            diet_type: Type of diet
            health_goal: Optional health goal

        Returns:
            Dictionary with macro and micro requirements
        """
        macros = nutrition_calculator.calculate_macros(
            target_calories=target_calories,
            diet_type=diet_type,
        )

        # Get base micronutrient recommendations
        micros = nutrition_calculator.calculate_micronutrients(
            age=30,  # Default for calculation
            gender="male",  # Default for calculation
        )

        return {
            "daily_calories": target_calories,
            "macronutrients": macros,
            "micronutrients": micros,
            "diet_type": diet_type.value,
        }


# Singleton instance
meal_service = MealService()
