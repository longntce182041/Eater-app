"""
Tests for metabolism calculator service.
"""
import pytest

from app.core.constants import ActivityLevel, Gender, HealthGoal
from app.services.ai.metabolism_calculator import metabolism_calculator


class TestMetabolismCalculator:
    """Tests for MetabolismCalculator."""

    def test_bmr_harris_benedict_male(self):
        """Test BMR calculation for male using Harris-Benedict."""
        bmr = metabolism_calculator.calculate_bmr_harris_benedict(
            weight_kg=75,
            height_cm=175,
            age=30,
            gender=Gender.MALE,
        )
        assert 1700 < bmr < 1900  # Expected range for this profile

    def test_bmr_harris_benedict_female(self):
        """Test BMR calculation for female using Harris-Benedict."""
        bmr = metabolism_calculator.calculate_bmr_harris_benedict(
            weight_kg=60,
            height_cm=165,
            age=25,
            gender=Gender.FEMALE,
        )
        assert 1300 < bmr < 1500  # Expected range for this profile

    def test_bmr_mifflin_st_jeor(self):
        """Test BMR calculation using Mifflin-St Jeor."""
        bmr = metabolism_calculator.calculate_bmr_mifflin_st_jeor(
            weight_kg=70,
            height_cm=170,
            age=35,
            gender=Gender.MALE,
        )
        assert bmr > 0

    def test_tdee_calculation(self):
        """Test TDEE calculation with different activity levels."""
        bmr = 1600

        tdee_sedentary = metabolism_calculator.calculate_tdee(
            bmr, ActivityLevel.SEDENTARY
        )
        tdee_active = metabolism_calculator.calculate_tdee(
            bmr, ActivityLevel.VERY_ACTIVE
        )

        assert tdee_sedentary < tdee_active
        assert tdee_sedentary == bmr * 1.2

    def test_target_calories_weight_loss(self):
        """Test target calories for weight loss goal."""
        tdee = 2000
        target = metabolism_calculator.calculate_target_calories(
            tdee, HealthGoal.WEIGHT_LOSS
        )
        assert target == 1500  # 500 calorie deficit

    def test_target_calories_minimum(self):
        """Test that target calories don't go below minimum."""
        tdee = 1400
        target = metabolism_calculator.calculate_target_calories(
            tdee, HealthGoal.WEIGHT_LOSS
        )
        assert target >= 1200  # Minimum healthy calories

    def test_full_calculation(self):
        """Test complete metabolism calculation."""
        result = metabolism_calculator.get_full_calculation(
            weight_kg=75,
            height_cm=175,
            age=30,
            gender=Gender.MALE,
            activity_level=ActivityLevel.MODERATELY_ACTIVE,
            health_goal=HealthGoal.MAINTENANCE,
        )

        assert "bmr_harris_benedict" in result
        assert "bmr_mifflin_st_jeor" in result
        assert "tdee" in result
        assert "target_calories" in result
        assert result["target_calories"] > 0
