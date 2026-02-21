"""
FastAPI endpoints for AI Meal Planning Pipeline

Exposes the complete 3-step pipeline as a REST API.
"""
from fastapi import APIRouter, HTTPException, status
from app.api.schemas.meal_plan_pipeline import (
    MealPlanPipelineRequest,
    MealPlanPipelineResponse,
    DietaryPreferencesInput,
    DietaryPreferencesOutput,
    HealthGoalInput,
    HealthGoalOutput,
    MealPlanGenerationInput,
    MealPlanGenerationOutput
)
from app.services.meal_plan_pipeline_service import get_pipeline_service
from app.services.ai_core.meal_planning.dietary_analyzer import analyze_dietary_preferences
from app.services.ai_core.meal_planning.goal_analyzer import analyze_health_goal
from app.services.ai_core.meal_planning.meal_plan_generator import generate_meal_plan
import logging

logger = logging.getLogger(__name__)

router = APIRouter()


@router.post(
    "/complete-pipeline",
    response_model=MealPlanPipelineResponse,
    summary="Execute Complete AI Meal Planning Pipeline",
    description="""
    Execute the complete 3-step AI meal planning pipeline:
    
    **Step 1: Analyze Dietary Preferences**
    - Normalizes diet types and excluded ingredients
    - Validates against supported diet list
    - Output: diet_constraints
    
    **Step 2: Analyze Health Goals**
    - Interprets health objective (weight loss, muscle gain, etc.)
    - Calculates calorie adjustment and target calories
    - Determines macro priorities
    - Output: goal_profile
    
    **Step 3: Generate Personalized Meal Plan (Core)**
    - Filters recipes by diet constraints
    - Matches target calories within ±10% tolerance
    - Distributes macros across meals
    - Assembles complete meal plan
    - Output: meal_plan
    
    Returns results from all 3 steps plus metadata.
    """,
    status_code=status.HTTP_200_OK
)
async def execute_complete_pipeline(
    request: MealPlanPipelineRequest
):
    """
    Execute the complete AI meal planning pipeline.
    
    This is the main production endpoint that orchestrates all 3 functions.
    """
    try:
        logger.info(f"Received pipeline request for user {request.user_id}")
        
        # Get pipeline service
        pipeline_service = get_pipeline_service()
        
        # Validate request
        is_valid, error_message = pipeline_service.validate_request(request)
        if not is_valid:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=error_message
            )
        
        # Execute pipeline
        response = await pipeline_service.execute_pipeline(request)
        
        logger.info(f"Pipeline executed successfully for user {request.user_id}")
        return response
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Pipeline execution failed: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Pipeline execution failed: {str(e)}"
        )


@router.post(
    "/step1/analyze-dietary-preferences",
    response_model=DietaryPreferencesOutput,
    summary="Step 1: Analyze Dietary Preferences",
    description="""
    Analyze dietary preferences and produce normalized diet constraints.
    
    This is Function 1 of the pipeline, exposed as a standalone endpoint.
    
    **Purpose**: Build diet constraints for meal planning
    
    **Processing**:
    - Normalize all ingredient names to lowercase
    - Merge allergies + disliked_ingredients
    - Remove duplicates
    - Validate diet_types against supported list
    
    **Output**: Clean structured diet_constraints object
    """,
    status_code=status.HTTP_200_OK,
    tags=["Pipeline Steps"]
)
async def analyze_dietary_preferences_endpoint(
    preferences: DietaryPreferencesInput
):
    """
    Execute Step 1: Analyze Dietary Preferences.
    
    Standalone endpoint for testing or partial pipeline execution.
    """
    try:
        logger.info("Executing Step 1: Analyze Dietary Preferences")
        
        result = analyze_dietary_preferences(
            diet_types=preferences.diet_types,
            allergies=preferences.allergies,
            disliked_ingredients=preferences.disliked_ingredients
        )
        
        logger.info(f"Step 1 complete: {len(result.diet_constraints.diet_types)} diets, "
                   f"{len(result.diet_constraints.excluded_ingredients)} exclusions")
        
        return result
        
    except Exception as e:
        logger.error(f"Step 1 failed: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Dietary preferences analysis failed: {str(e)}"
        )


@router.post(
    "/step2/analyze-health-goals",
    response_model=HealthGoalOutput,
    summary="Step 2: Analyze Health Goals",
    description="""
    Analyze health goals and produce goal profile with calorie/macro strategy.
    
    This is Function 2 of the pipeline, exposed as a standalone endpoint.
    
    **Purpose**: Define optimization direction for meal planning
    
    **Processing**:
    - Map goal to calorie adjustment
    - Compute target calories from TDEE
    - Apply safe bounds (no extreme deficit/surplus)
    - Determine macro priorities
    
    **Output**: goal_profile with numeric nutrition targets
    """,
    status_code=status.HTTP_200_OK,
    tags=["Pipeline Steps"]
)
async def analyze_health_goals_endpoint(
    goal_input: HealthGoalInput
):
    """
    Execute Step 2: Analyze Health Goals.
    
    Standalone endpoint for testing or partial pipeline execution.
    """
    try:
        logger.info(f"Executing Step 2: Analyze Health Goals - {goal_input.health_goal}")
        
        result = analyze_health_goal(
            health_goal=goal_input.health_goal,
            user_tdee=goal_input.user_tdee,
            target_weight=goal_input.target_weight,
            timeline_weeks=goal_input.timeline_weeks
        )
        
        logger.info(f"Step 2 complete: adjustment={result.goal_profile.calorie_adjustment}, "
                   f"target={result.goal_profile.target_calories}")
        
        return result
        
    except Exception as e:
        logger.error(f"Step 2 failed: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Health goal analysis failed: {str(e)}"
        )


@router.post(
    "/step3/generate-meal-plan",
    response_model=MealPlanGenerationOutput,
    summary="Step 3: Generate Personalized Meal Plan (Core)",
    description="""
    Generate personalized meal plan using metabolic data and constraints.
    
    This is Function 3 of the pipeline - the CORE AI engine.
    
    **Purpose**: Assemble meals that satisfy nutrition targets and restrictions
    
    **Processing**:
    - Filter recipes by diet constraints
    - Match target calories within ±10%
    - Distribute macros across meals
    - Select high-score recipes
    - Balance nutrition
    
    **Output**: Complete meal_plan with meals and nutrition totals
    
    **Note**: Requires outputs from Step 1 and Step 2 as inputs
    """,
    status_code=status.HTTP_200_OK,
    tags=["Pipeline Steps"]
)
async def generate_meal_plan_endpoint(
    generation_input: MealPlanGenerationInput
):
    """
    Execute Step 3: Generate Personalized Meal Plan.
    
    Standalone endpoint for testing or when you already have
    diet_constraints and goal_profile from previous steps.
    """
    try:
        logger.info("Executing Step 3: Generate Personalized Meal Plan")
        
        # Generate meal plan (days parameter currently not fully used in implementation)
        result = generate_meal_plan(
            body_profile=generation_input.body_profile,
            diet_constraints=generation_input.diet_constraints,
            goal_profile=generation_input.goal_profile,
            recipe_database=None  # Uses mock database
        )
        
        logger.info(f"Step 3 complete: {len(result.meal_plan.meals)} meals, "
                   f"{result.meal_plan.daily_calories:.0f} calories")
        
        return result
        
    except Exception as e:
        logger.error(f"Step 3 failed: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Meal plan generation failed: {str(e)}"
        )


@router.get(
    "/supported-diet-types",
    summary="Get Supported Diet Types",
    description="Returns list of all supported diet types for Step 1",
    status_code=status.HTTP_200_OK,
    tags=["Utilities"]
)
async def get_supported_diet_types():
    """Get list of supported diet types"""
    from app.services.ai_core.meal_planning.dietary_analyzer import SUPPORTED_DIET_TYPES
    
    return {
        "supported_diet_types": sorted(list(SUPPORTED_DIET_TYPES)),
        "count": len(SUPPORTED_DIET_TYPES)
    }
