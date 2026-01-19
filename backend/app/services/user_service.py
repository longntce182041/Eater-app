"""
User Service

Business logic for user-related operations.
"""
from typing import Optional

from app.schemas.user import UserProfile, UserProfileAnalysis
from app.services.ai.profile_analyzer import profile_analyzer
from app.services.ai.metabolism_calculator import metabolism_calculator


class UserService:
    """Business logic for user operations."""

    def analyze_user_profile(self, profile: UserProfile) -> UserProfileAnalysis:
        """
        Analyze user profile and calculate nutritional requirements.

        Args:
            profile: User profile data

        Returns:
            Complete profile analysis with metabolic calculations
        """
        # Get profile analysis
        analysis = profile_analyzer.analyze_profile(profile)

        # Calculate metabolism
        metabolism = metabolism_calculator.get_full_calculation(
            weight_kg=profile.weight_kg,
            height_cm=profile.height_cm,
            age=profile.age,
            gender=profile.gender,
            activity_level=profile.activity_level,
            health_goal=profile.health_goal,
        )

        return UserProfileAnalysis(
            user_id=profile.user_id,
            profile=profile,
            analysis=analysis,
            metabolism=metabolism,
            target_calories=metabolism["target_calories"],
            recommended_diet=analysis["recommended_diet_type"],
        )


# Singleton instance
user_service = UserService()
