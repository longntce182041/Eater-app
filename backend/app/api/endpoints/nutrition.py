"""
Nutrition calculation endpoints.
"""
from fastapi import APIRouter, HTTPException, status

from app.core.constants import Gender
from app.schemas.nutrition import (
    BMRCalculationRequest,
    BMRResponse,
    NutritionCalculationRequest,
    NutritionResponse,
)
from app.services.ai.metabolism_calculator import metabolism_calculator
from app.services.ai.nutrition_calculator import nutrition_calculator
from app.services.meal_service import meal_service

router = APIRouter()


@router.post(
    "/calculate",
    response_model=NutritionResponse,
    status_code=status.HTTP_200_OK,
)
async def calculate_nutrition(request: NutritionCalculationRequest):
    """
    Calculate complete nutrition requirements.

    Returns macro and micronutrient targets based on:
    - Daily calorie target
    - Diet type
    - Health goal
    - Age and gender (for micronutrients)

    Args:
        request: Nutrition calculation parameters

    Returns:
        Complete nutrition breakdown
    """
    try:
        result = meal_service.calculate_nutrition_requirements(
            target_calories=request.target_calories,
            diet_type=request.diet_type,
            health_goal=request.health_goal.value if request.health_goal else None,
        )
        return NutritionResponse(**result)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error calculating nutrition: {str(e)}",
        )


@router.post(
    "/bmr",
    response_model=BMRResponse,
    status_code=status.HTTP_200_OK,
)
async def calculate_bmr(request: BMRCalculationRequest):
    """
    Calculate Basal Metabolic Rate (BMR).

    Uses both Harris-Benedict and Mifflin-St Jeor equations.

    Args:
        request: BMR calculation parameters

    Returns:
        BMR values from different equations
    """
    try:
        bmr_harris = metabolism_calculator.calculate_bmr_harris_benedict(
            weight_kg=request.weight_kg,
            height_cm=request.height_cm,
            age=request.age,
            gender=request.gender,
        )

        bmr_mifflin = metabolism_calculator.calculate_bmr_mifflin_st_jeor(
            weight_kg=request.weight_kg,
            height_cm=request.height_cm,
            age=request.age,
            gender=request.gender,
        )

        return BMRResponse(
            bmr_harris_benedict=bmr_harris,
            bmr_mifflin_st_jeor=bmr_mifflin,
            bmr_used=bmr_mifflin,  # Mifflin is more modern
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error calculating BMR: {str(e)}",
        )


@router.post("/macros")
async def calculate_macros(
    target_calories: int,
    diet_type: str = "standard",
):
    """
    Quick macro calculation endpoint.

    Args:
        target_calories: Daily calorie target
        diet_type: Type of diet

    Returns:
        Macronutrient breakdown
    """
    try:
        from app.core.constants import DietType

        diet = DietType(diet_type)
        macros = nutrition_calculator.calculate_macros(
            target_calories=target_calories,
            diet_type=diet,
        )
        return {
            "target_calories": target_calories,
            "diet_type": diet_type,
            "macros": macros,
        }
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid diet type: {diet_type}",
        )
