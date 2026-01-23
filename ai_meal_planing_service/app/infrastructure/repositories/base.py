from typing import Protocol, List, Optional
from app.domain.models.meal import Meal


class RecipeRepository(Protocol):
    async def get_recommended_meals(
        self,
        dietary_style: str,
        allergies: list[str],
        dislikes: list[str],
    ) -> list[Meal]:
        ...


class UserRepository(Protocol):
    async def get_user_profile(self, user_id: str):
        ...


class MealPlanRepository(Protocol):
    async def save_meal_plan(self, meal_plan) -> None:
        ...

    async def get_recent_meal_plans(self, user_id: str):
        ...