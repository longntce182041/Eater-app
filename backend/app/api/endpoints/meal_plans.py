"""
Meal plan endpoints for AI-powered meal plan generation.
"""
from fastapi import APIRouter, HTTPException, status

from app.schemas.meal_plan import MealPlanRequest, MealPlanResponse
from app.services.meal_service import meal_service

router = APIRouter()


@router.post(
    "/generate",
    response_model=MealPlanResponse,
    status_code=status.HTTP_201_CREATED,
)
async def generate_meal_plan(request: MealPlanRequest):
    """
    Generate an AI-powered meal plan.

    This endpoint generates either a daily or weekly meal plan based on:
    - Target calories and diet type
    - Dietary restrictions and allergies
    - User preferences

    The AI uses rule-based algorithms to:
    - Distribute calories across meals
    - Balance macronutrients
    - Ensure variety
    - Respect dietary restrictions

    Args:
        request: Meal plan generation parameters

    Returns:
        Generated meal plan with meals and nutrition info
    """
    try:
        plan = meal_service.generate_meal_plan(request)
        return plan
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e),
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error generating meal plan: {str(e)}",
        )


@router.get("/{plan_id}")
async def get_meal_plan(plan_id: str):
    """
    Get a specific meal plan by ID.

    Args:
        plan_id: Unique meal plan identifier

    Returns:
        Meal plan details
    """
    # TODO: Implement database lookup
    # For now, return a placeholder response
    return {
        "id": plan_id,
        "message": "Meal plan retrieval not yet implemented",
        "status": "placeholder",
    }


@router.delete("/{plan_id}")
async def delete_meal_plan(plan_id: str):
    """
    Delete a meal plan.

    Args:
        plan_id: Unique meal plan identifier

    Returns:
        Deletion confirmation
    """
    # TODO: Implement database deletion
    return {
        "id": plan_id,
        "deleted": True,
        "message": "Meal plan deletion not yet implemented",
    }


@router.post("/{plan_id}/regenerate")
async def regenerate_meal_plan(plan_id: str, request: MealPlanRequest):
    """
    Regenerate a meal plan with new parameters.

    Useful when user wants to refresh their plan or change preferences.

    Args:
        plan_id: Existing plan ID to replace
        request: New generation parameters

    Returns:
        Newly generated meal plan
    """
    try:
        # Generate new plan
        new_plan = meal_service.generate_meal_plan(request)

        # TODO: Delete old plan and save new one

        return {
            "old_plan_id": plan_id,
            "new_plan": new_plan,
            "message": "Plan regenerated successfully",
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error regenerating meal plan: {str(e)}",
        )
