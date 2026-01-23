from fastapi import APIRouter, Depends
from app.api.v1.schemas.meal_planning import GenerateMealPlanRequest, MealPlanResponse

# from app.services.meal_planning_service import MealPlanningService
# dependency injection placeholder
def get_meal_planning_service():
    # TODO: wire repositories, ai_core, etc.
    raise NotImplementedError


router = APIRouter()

@router.post(
    "/generate",
    response_model=MealPlanResponse,
    summary="Generate AI Meal Plan",
)
async def generate_meal_plan(
    payload: GenerateMealPlanRequest,
    meal_planning_service = Depends(get_meal_planning_service),
):
    """Public API for other backends (Node, etc.) or frontends."""
    # plan = await meal_planning_service.generate_and_optimize_plan(
    #     user_id=payload.user_id,
    #     days=payload.days,
    # )
    # return MealPlanResponse(...)
    raise NotImplementedError