from typing import List
from app.domain.models.meal import Meal
from app.domain.models.user_profile import UserProfile
from app.domain.models.dietary_preferences import DietaryPreferences


class MLRecommender:
    """Optional ML-based recommender. Can be turned off in config."""

    async def recommend_meals(
        self,
        user: UserProfile,
        preferences: DietaryPreferences,
        candidate_meals: List[Meal],
    ) -> List[Meal]:
        """Return re-ranked meals based on ML/LLM model."""
        raise NotImplementedError