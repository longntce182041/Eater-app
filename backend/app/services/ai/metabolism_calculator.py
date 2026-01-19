"""
Metabolism Calculator Service

Calculates Basal Metabolic Rate (BMR) and Total Daily Energy Expenditure (TDEE)
using standard metabolic equations.
"""
from app.core.constants import (
    ACTIVITY_MULTIPLIERS,
    GOAL_CALORIE_ADJUSTMENTS,
    ActivityLevel,
    Gender,
    HealthGoal,
)


class MetabolismCalculator:
    """Calculates BMR and TDEE using rule-based formulas."""

    def calculate_bmr_harris_benedict(
        self,
        weight_kg: float,
        height_cm: float,
        age: int,
        gender: Gender,
    ) -> float:
        """
        Calculate BMR using Harris-Benedict equation.

        Args:
            weight_kg: Weight in kilograms
            height_cm: Height in centimeters
            age: Age in years
            gender: Gender (male/female)

        Returns:
            BMR in calories/day
        """
        if gender == Gender.MALE:
            bmr = 88.362 + (13.397 * weight_kg) + (4.799 * height_cm) - (5.677 * age)
        else:
            bmr = 447.593 + (9.247 * weight_kg) + (3.098 * height_cm) - (4.330 * age)

        return round(bmr, 2)

    def calculate_bmr_mifflin_st_jeor(
        self,
        weight_kg: float,
        height_cm: float,
        age: int,
        gender: Gender,
    ) -> float:
        """
        Calculate BMR using Mifflin-St Jeor equation (more accurate for modern populations).

        Args:
            weight_kg: Weight in kilograms
            height_cm: Height in centimeters
            age: Age in years
            gender: Gender (male/female)

        Returns:
            BMR in calories/day
        """
        bmr = (10 * weight_kg) + (6.25 * height_cm) - (5 * age)

        if gender == Gender.MALE:
            bmr += 5
        else:
            bmr -= 161

        return round(bmr, 2)

    def calculate_tdee(
        self,
        bmr: float,
        activity_level: ActivityLevel,
    ) -> float:
        """
        Calculate Total Daily Energy Expenditure.

        Args:
            bmr: Basal Metabolic Rate
            activity_level: User's activity level

        Returns:
            TDEE in calories/day
        """
        multiplier = ACTIVITY_MULTIPLIERS.get(activity_level, 1.2)
        tdee = bmr * multiplier
        return round(tdee, 2)

    def calculate_target_calories(
        self,
        tdee: float,
        health_goal: HealthGoal,
    ) -> int:
        """
        Calculate target daily calories based on health goal.

        Args:
            tdee: Total Daily Energy Expenditure
            health_goal: User's health/fitness goal

        Returns:
            Target calories/day
        """
        adjustment = GOAL_CALORIE_ADJUSTMENTS.get(health_goal, 0)
        target = tdee + adjustment

        # Ensure minimum healthy calories
        min_calories = 1200
        return max(int(target), min_calories)

    def get_full_calculation(
        self,
        weight_kg: float,
        height_cm: float,
        age: int,
        gender: Gender,
        activity_level: ActivityLevel,
        health_goal: HealthGoal,
    ) -> dict:
        """
        Perform complete metabolism calculation.

        Returns:
            Dictionary with BMR, TDEE, and target calories
        """
        # Calculate BMR using both methods
        bmr_harris = self.calculate_bmr_harris_benedict(
            weight_kg, height_cm, age, gender
        )
        bmr_mifflin = self.calculate_bmr_mifflin_st_jeor(
            weight_kg, height_cm, age, gender
        )

        # Use average or Mifflin (more modern)
        bmr = bmr_mifflin

        # Calculate TDEE
        tdee = self.calculate_tdee(bmr, activity_level)

        # Calculate target calories
        target_calories = self.calculate_target_calories(tdee, health_goal)

        return {
            "bmr_harris_benedict": bmr_harris,
            "bmr_mifflin_st_jeor": bmr_mifflin,
            "bmr_used": bmr,
            "activity_multiplier": ACTIVITY_MULTIPLIERS.get(activity_level),
            "tdee": tdee,
            "goal_adjustment": GOAL_CALORIE_ADJUSTMENTS.get(health_goal, 0),
            "target_calories": target_calories,
        }


# Singleton instance
metabolism_calculator = MetabolismCalculator()
