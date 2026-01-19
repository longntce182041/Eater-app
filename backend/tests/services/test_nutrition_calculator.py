"""
Tests for nutrition calculator service.
"""
import pytest

from app.core.constants import DietType, HealthGoal
from app.services.ai.nutrition_calculator import nutrition_calculator


class TestNutritionCalculator:
    """Tests for NutritionCalculator."""

    def test_calculate_macros_standard(self):
        """Test macro calculation for standard diet."""
        macros = nutrition_calculator.calculate_macros(
            target_calories=2000,
            diet_type=DietType.STANDARD,
        )

        assert "protein_grams" in macros
        assert "carbohydrates_grams" in macros
        assert "fat_grams" in macros
        assert macros["total_calories"] == 2000

    def test_calculate_macros_keto(self):
        """Test macro calculation for keto diet (high fat, low carb)."""
        macros = nutrition_calculator.calculate_macros(
            target_calories=2000,
            diet_type=DietType.KETO,
        )

        # Keto should have high fat percentage
        assert macros["fat_percent"] > 70
        assert macros["carbohydrates_percent"] < 10

    def test_calculate_macros_high_protein(self):
        """Test macro calculation for high protein diet."""
        macros = nutrition_calculator.calculate_macros(
            target_calories=2000,
            diet_type=DietType.HIGH_PROTEIN,
        )

        assert macros["protein_percent"] >= 40

    def test_muscle_gain_adjustment(self):
        """Test that muscle gain goal increases protein."""
        standard = nutrition_calculator.calculate_macros(
            target_calories=2000,
            diet_type=DietType.STANDARD,
        )

        muscle_gain = nutrition_calculator.calculate_macros(
            target_calories=2000,
            diet_type=DietType.STANDARD,
            health_goal=HealthGoal.MUSCLE_GAIN,
        )

        assert muscle_gain["protein_grams"] > standard["protein_grams"]

    def test_calculate_micronutrients_male(self):
        """Test micronutrient calculation for male."""
        micros = nutrition_calculator.calculate_micronutrients(
            age=30,
            gender="male",
        )

        assert micros["vitamin_a_mcg"] == 900
        assert micros["iron_mg"] == 8
        assert micros["fiber_g"] == 38

    def test_calculate_micronutrients_female(self):
        """Test micronutrient calculation for female."""
        micros = nutrition_calculator.calculate_micronutrients(
            age=30,
            gender="female",
        )

        assert micros["vitamin_a_mcg"] == 700
        assert micros["iron_mg"] == 18  # Higher for women
        assert micros["fiber_g"] == 25

    def test_micronutrients_age_adjustment(self):
        """Test that micronutrients adjust for age."""
        young = nutrition_calculator.calculate_micronutrients(age=25, gender="male")
        older = nutrition_calculator.calculate_micronutrients(age=75, gender="male")

        # Vitamin D increases with age
        assert older["vitamin_d_mcg"] > young["vitamin_d_mcg"]

    def test_meal_nutrition_calculation(self):
        """Test meal-level nutrition calculation."""
        daily_macros = nutrition_calculator.calculate_macros(
            target_calories=2000,
            diet_type=DietType.STANDARD,
        )

        meal_nutrition = nutrition_calculator.calculate_meal_nutrition(
            daily_macros=daily_macros,
            meal_ratio=0.25,  # Breakfast
        )

        # Should be 25% of daily values
        assert meal_nutrition["total_calories"] == 500
