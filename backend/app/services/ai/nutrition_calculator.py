"""
Nutrition Calculator Service

Calculates macro and micronutrient requirements based on user profile
and dietary preferences.
"""
from typing import Dict, Optional

from app.core.constants import (
    DEFAULT_MACRO_RATIOS,
    DIET_MACRO_RATIOS,
    DietType,
    HealthGoal,
)


class NutritionCalculator:
    """Calculates nutritional requirements using rule-based algorithms."""

    # Calories per gram for macronutrients
    CALORIES_PER_GRAM = {
        "protein": 4,
        "carbohydrates": 4,
        "fat": 9,
    }

    def calculate_macros(
        self,
        target_calories: int,
        diet_type: DietType = DietType.STANDARD,
        health_goal: Optional[HealthGoal] = None,
    ) -> Dict[str, float]:
        """
        Calculate macronutrient targets in grams.

        Args:
            target_calories: Daily calorie target
            diet_type: Type of diet
            health_goal: User's health goal

        Returns:
            Dictionary with macro targets in grams
        """
        # Get macro ratios for diet type
        ratios = DIET_MACRO_RATIOS.get(diet_type, DEFAULT_MACRO_RATIOS)

        # Adjust ratios for specific goals
        if health_goal == HealthGoal.MUSCLE_GAIN:
            ratios = self._adjust_for_muscle_gain(ratios)
        elif health_goal == HealthGoal.WEIGHT_LOSS:
            ratios = self._adjust_for_weight_loss(ratios)

        # Calculate grams from calories
        macros = {}
        for macro, ratio in ratios.items():
            calories_from_macro = target_calories * ratio
            grams = calories_from_macro / self.CALORIES_PER_GRAM[macro]
            macros[f"{macro}_grams"] = round(grams, 1)
            macros[f"{macro}_calories"] = round(calories_from_macro, 1)
            macros[f"{macro}_percent"] = round(ratio * 100, 1)

        macros["total_calories"] = target_calories
        return macros

    def _adjust_for_muscle_gain(self, ratios: Dict[str, float]) -> Dict[str, float]:
        """Adjust macro ratios for muscle gain (higher protein)."""
        adjusted = ratios.copy()
        protein_boost = 0.05

        adjusted["protein"] = min(adjusted["protein"] + protein_boost, 0.40)
        # Reduce carbs slightly to compensate
        adjusted["carbohydrates"] = max(adjusted["carbohydrates"] - protein_boost, 0.30)

        return adjusted

    def _adjust_for_weight_loss(self, ratios: Dict[str, float]) -> Dict[str, float]:
        """Adjust macro ratios for weight loss (higher protein for satiety)."""
        adjusted = ratios.copy()
        protein_boost = 0.05

        adjusted["protein"] = min(adjusted["protein"] + protein_boost, 0.35)
        # Reduce fat slightly
        adjusted["fat"] = max(adjusted["fat"] - protein_boost, 0.20)

        return adjusted

    def calculate_micronutrients(
        self,
        age: int,
        gender: str,
        health_conditions: Optional[list] = None,
    ) -> Dict[str, float]:
        """
        Calculate recommended daily micronutrient intake.

        Args:
            age: User's age
            gender: User's gender
            health_conditions: List of health conditions

        Returns:
            Dictionary with micronutrient recommendations
        """
        # Base recommendations (in mg or mcg as labeled)
        micros = {
            "vitamin_a_mcg": 900 if gender == "male" else 700,
            "vitamin_c_mg": 90 if gender == "male" else 75,
            "vitamin_d_mcg": 15 if age < 70 else 20,
            "vitamin_e_mg": 15,
            "vitamin_k_mcg": 120 if gender == "male" else 90,
            "calcium_mg": 1000 if age < 50 else 1200,
            "iron_mg": 8 if gender == "male" else 18,
            "magnesium_mg": 420 if gender == "male" else 320,
            "potassium_mg": 3400 if gender == "male" else 2600,
            "sodium_mg": 2300,  # Max recommended
            "zinc_mg": 11 if gender == "male" else 8,
            "fiber_g": 38 if gender == "male" else 25,
        }

        # Adjust for health conditions
        if health_conditions:
            micros = self._adjust_for_conditions(micros, health_conditions)

        return micros

    def _adjust_for_conditions(
        self,
        micros: Dict[str, float],
        conditions: list,
    ) -> Dict[str, float]:
        """Adjust micronutrient targets for health conditions."""
        adjusted = micros.copy()

        if "hypertension" in conditions:
            adjusted["sodium_mg"] = 1500  # Lower sodium
            adjusted["potassium_mg"] *= 1.1  # Higher potassium

        if "osteoporosis" in conditions:
            adjusted["calcium_mg"] = 1200
            adjusted["vitamin_d_mcg"] = 20

        if "anemia" in conditions:
            adjusted["iron_mg"] *= 1.5

        return adjusted

    def calculate_meal_nutrition(
        self,
        daily_macros: Dict[str, float],
        meal_ratio: float,
    ) -> Dict[str, float]:
        """
        Calculate nutrition targets for a single meal.

        Args:
            daily_macros: Daily macro targets
            meal_ratio: Proportion of daily intake for this meal

        Returns:
            Dictionary with meal-level nutrition targets
        """
        meal_nutrition = {}
        for key, value in daily_macros.items():
            if isinstance(value, (int, float)):
                meal_nutrition[key] = round(value * meal_ratio, 1)

        return meal_nutrition


# Singleton instance
nutrition_calculator = NutritionCalculator()
