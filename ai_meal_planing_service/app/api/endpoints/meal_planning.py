from fastapi import APIRouter, HTTPException, status
from app.api.schemas.meal_planning import GenerateMealPlanRequest, MealPlanResponse
from datetime import datetime
import logging

logger = logging.getLogger(__name__)

router = APIRouter()

@router.post(
    "/generate",
    response_model=MealPlanResponse,
    summary="Generate AI Meal Plan",
    status_code=status.HTTP_201_CREATED,
)
async def generate_meal_plan(
    payload: GenerateMealPlanRequest,
):
    """
    Generate an AI-powered meal plan for a user.
    
    This endpoint receives user data from the Node.js backend and generates
    a personalized meal plan based on dietary preferences, health metrics,
    and nutritional targets.
    """
    try:
        logger.info(f"Generating meal plan for user {payload.user_id}, days: {payload.days}")
        
        # TODO: Implement full meal planning logic with repositories
        # For now, return a mock successful response to establish connection
        
        # Validate input
        if payload.days < 1 or payload.days > 30:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Days must be between 1 and 30"
            )
        
        # Mock meal plan response (will be replaced with actual implementation)
        response = MealPlanResponse(
            user_id=payload.user_id,
            days=payload.days,
            status="generated",
            message=f"Meal plan for {payload.days} days generated successfully",
            created_at=datetime.utcnow().isoformat(),
        )
        
        logger.info(f"Meal plan generated successfully for user {payload.user_id}")
        return response
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error generating meal plan: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to generate meal plan: {str(e)}"
        )