"""
Profile Analyzer Service

Analyzes user profile and dietary preferences to determine
nutritional requirements and dietary constraints.
"""
from typing import List, Optional

from app.core.constants import (
    ActivityLevel,
    DietType,
    Gender,
    HealthGoal,
)
from app.schemas.user import UserProfile


class ProfileAnalyzer:
    """Analyzes user profiles to determine nutritional needs and constraints."""

    def analyze_profile(self, profile: UserProfile) -> dict:
        """
        Analyze user profile and return comprehensive analysis.

        Args:
            profile: User profile data

        Returns:
            Dictionary with profile analysis results
        """
        return {
            "activity_category": self._categorize_activity(profile.activity_level),
            "dietary_restrictions": self._get_dietary_restrictions(profile),
            "health_priorities": self._determine_health_priorities(profile),
            "recommended_diet_type": self._recommend_diet_type(profile),
            "calorie_adjustment_factor": self._get_calorie_adjustment(profile),
        }

    def _categorize_activity(self, activity_level: ActivityLevel) -> str:
        """Categorize user activity level into broad categories."""
        low_activity = [ActivityLevel.SEDENTARY, ActivityLevel.LIGHTLY_ACTIVE]
        high_activity = [ActivityLevel.VERY_ACTIVE, ActivityLevel.EXTRA_ACTIVE]

        if activity_level in low_activity:
            return "low"
        elif activity_level in high_activity:
            return "high"
        return "moderate"

    def _get_dietary_restrictions(self, profile: UserProfile) -> List[str]:
        """Extract dietary restrictions from profile."""
        restrictions = []

        # Add allergies
        if profile.allergies:
            restrictions.extend(profile.allergies)

        # Add intolerances
        if profile.intolerances:
            restrictions.extend(profile.intolerances)

        # Add diet-specific restrictions
        if profile.diet_type == DietType.VEGETARIAN:
            restrictions.extend(["meat", "poultry", "fish"])
        elif profile.diet_type == DietType.VEGAN:
            restrictions.extend(["meat", "poultry", "fish", "dairy", "eggs", "honey"])
        elif profile.diet_type == DietType.KETO:
            restrictions.extend(["high_carb_foods", "sugar", "grains"])
        elif profile.diet_type == DietType.PALEO:
            restrictions.extend(["grains", "legumes", "dairy", "processed_foods"])

        return list(set(restrictions))

    def _determine_health_priorities(self, profile: UserProfile) -> List[str]:
        """Determine health priorities based on user goals and conditions."""
        priorities = []

        if profile.health_goal == HealthGoal.WEIGHT_LOSS:
            priorities.extend(["calorie_deficit", "high_fiber", "protein_preservation"])
        elif profile.health_goal == HealthGoal.MUSCLE_GAIN:
            priorities.extend(["high_protein", "calorie_surplus", "post_workout_nutrition"])
        elif profile.health_goal == HealthGoal.WEIGHT_GAIN:
            priorities.extend(["calorie_surplus", "nutrient_density", "frequent_meals"])

        # Add medical condition priorities
        if profile.medical_conditions:
            if "diabetes" in profile.medical_conditions:
                priorities.extend(["low_glycemic", "blood_sugar_control"])
            if "hypertension" in profile.medical_conditions:
                priorities.extend(["low_sodium", "heart_healthy"])

        return priorities

    def _recommend_diet_type(self, profile: UserProfile) -> DietType:
        """Recommend optimal diet type based on profile."""
        if profile.diet_type:
            return profile.diet_type

        # Rule-based recommendation
        if profile.health_goal == HealthGoal.WEIGHT_LOSS:
            return DietType.LOW_CARB
        elif profile.health_goal == HealthGoal.MUSCLE_GAIN:
            return DietType.HIGH_PROTEIN
        elif profile.health_goal == HealthGoal.IMPROVE_HEALTH:
            return DietType.MEDITERRANEAN

        return DietType.STANDARD

    def _get_calorie_adjustment(self, profile: UserProfile) -> float:
        """Calculate calorie adjustment factor based on profile."""
        adjustment = 1.0

        # Age adjustment (metabolism slows with age)
        if profile.age:
            if profile.age > 50:
                adjustment *= 0.95
            elif profile.age > 60:
                adjustment *= 0.90

        return adjustment


# Singleton instance
profile_analyzer = ProfileAnalyzer()
