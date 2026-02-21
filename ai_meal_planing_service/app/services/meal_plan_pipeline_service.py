"""
AI Meal Plan Pipeline Service

Orchestrates the complete 3-step pipeline:
1. Analyze Dietary Preferences
2. Analyze Health Goals  
3. Generate Personalized Meal Plan

This service coordinates the flow between all three functions.
"""
from typing import Optional, List, Dict, Any
from app.api.schemas.meal_plan_pipeline import (
    MealPlanPipelineRequest,
    MealPlanPipelineResponse,
    BodyProfile,
    DietaryPreferencesInput,
    HealthGoalInput
)
from app.services.ai_core.meal_planning.dietary_analyzer import analyze_dietary_preferences
from app.services.ai_core.meal_planning.goal_analyzer import analyze_health_goal
from app.services.ai_core.meal_planning.meal_plan_generator import generate_meal_plan
import logging

logger = logging.getLogger(__name__)


class MealPlanPipelineService:
    """
    Orchestrator service for the complete AI meal planning pipeline.
    
    This service executes the pipeline in strict order:
    Step 1 → Step 2 → Step 3
    
    Each step's output becomes input to the next step.
    """
    
    def __init__(self, recipe_database: Optional[List[Dict[str, Any]]] = None):
        """
        Initialize the pipeline service.
        
        Args:
            recipe_database: Optional recipe database for meal generation
        """
        self.recipe_database = recipe_database
    
    async def execute_pipeline(
        self,
        request: MealPlanPipelineRequest
    ) -> MealPlanPipelineResponse:
        """
        Execute the complete AI meal planning pipeline.
        
        UPSTREAM INTEGRATION:
        ─────────────────────
        Accepts body_profile from 'Analyze User Profile' function.
        Does NOT recalculate BMR/TDEE if already provided.
        Trusts upstream metabolic calculations.
        
        Pipeline Flow:
        ┌─────────────────────────────────────────┐
        │ UPSTREAM: Analyze User Profile          │
        │ Output: body_profile (BMR, TDEE, BMI)   │
        └─────────────┬───────────────────────────┘
                      ↓
        ┌─────────────────────────────────────────┐
        │ INPUT: body_profile + preferences       │
        └─────────────┬───────────────────────────┘
                      ↓
        ┌─────────────────────────────────────────┐
        │ STEP 1: Analyze Dietary Preferences     │
        │ Output: diet_constraints                │
        └─────────────┬───────────────────────────┘
                      ↓
        ┌─────────────────────────────────────────┐
        │ STEP 2: Analyze Health Goals            │
        │ Input: diet_constraints (passed)        │
        │ Output: goal_profile                    │
        └─────────────┬───────────────────────────┘
                      ↓
        ┌─────────────────────────────────────────┐
        │ STEP 3: Generate Meal Plan (Core)       │
        │ Input: body_profile + diet_constraints  │
        │        + goal_profile                   │
        │ Output: meal_plan                       │
        └─────────────┬───────────────────────────┘
                      ↓
        ┌─────────────────────────────────────────┐
        │ OUTPUT: Complete Pipeline Response      │
        └─────────────────────────────────────────┘
        
        Args:
            request: Complete pipeline request with all user data
            
        Returns:
            MealPlanPipelineResponse with results from all 3 steps
        """
        logger.info(f"Starting pipeline execution for user {request.user_id}")
        
        # ================================================================
        # PREPARE BODY PROFILE (from upstream or fallback)
        # ================================================================
        if request.body_profile:
            logger.info("Using body_profile from upstream 'Analyze User Profile' function")
            body_profile = request.body_profile
        else:
            logger.info("Constructing body_profile from individual fields (fallback mode)")
            # Validate required fields for fallback
            if not all([request.bmr, request.tdee, request.weight_kg, 
                       request.height_cm, request.age, request.gender]):
                raise ValueError(
                    "Either 'body_profile' or all individual fields "
                    "(bmr, tdee, weight_kg, height_cm, age, gender) must be provided"
                )
            
            body_profile = BodyProfile(
                bmr=request.bmr,
                tdee=request.tdee,
                weight_kg=request.weight_kg,
                height_cm=request.height_cm,
                age=request.age,
                gender=request.gender,
                bmi=None,
                activity_level=request.activity_level
            )
        
        logger.info(f"Body profile ready: BMR={body_profile.bmr}, TDEE={body_profile.tdee}")
        
        # ================================================================
        # STEP 1: ANALYZE DIETARY PREFERENCES
        # ================================================================
        logger.info("Step 1: Analyzing dietary preferences")
        
        dietary_result = analyze_dietary_preferences(
            diet_types=request.diet_types,
            allergies=request.allergies,
            disliked_ingredients=request.disliked_ingredients
        )
        
        diet_constraints = dietary_result.diet_constraints
        logger.info(f"Step 1 complete: {len(diet_constraints.diet_types)} diets, "
                   f"{len(diet_constraints.excluded_ingredients)} exclusions")
        
        # ================================================================
        # STEP 2: ANALYZE HEALTH GOALS
        # ================================================================
        logger.info("Step 2: Analyzing health goals")
        
        goal_result = analyze_health_goal(
            health_goal=request.health_goal,
            user_tdee=body_profile.tdee,  # Use TDEE from body_profile (upstream)
            target_weight=request.target_weight,
            timeline_weeks=request.timeline_weeks
        )
        
        goal_profile = goal_result.goal_profile
        logger.info(f"Step 2 complete: goal={goal_profile.primary_goal}, "
                   f"calorie_adjustment={goal_profile.calorie_adjustment}")
        
        # ================================================================
        # STEP 3: GENERATE PERSONALIZED MEAL PLAN (CORE)
        # ================================================================
        logger.info("Step 3: Generating personalized meal plan")
        
        # Body profile already prepared from upstream (no recalculation needed)
        meal_plan_result = generate_meal_plan(
            body_profile=body_profile,
            diet_constraints=diet_constraints,
            goal_profile=goal_profile,
            recipe_database=self.recipe_database
        )
        
        meal_plan = meal_plan_result.meal_plan
        generation_metadata = meal_plan_result.metadata
        
        logger.info(f"Step 3 complete: {len(meal_plan.meals)} meals, "
                   f"{meal_plan.daily_calories:.0f} calories")
        
        # ================================================================
        # ASSEMBLE PIPELINE RESPONSE
        # ================================================================
        
        pipeline_metadata = {
            "user_id": request.user_id,
            "pipeline_version": "1.0.0",
            "steps_executed": 3,
            "generation_metadata": generation_metadata
        }
        
        response = MealPlanPipelineResponse(
            user_id=request.user_id,
            diet_constraints=diet_constraints,
            goal_profile=goal_profile,
            meal_plan=meal_plan,
            pipeline_metadata=pipeline_metadata
        )
        
        logger.info(f"Pipeline execution complete for user {request.user_id}")
        
        return response
    
    def validate_request(self, request: MealPlanPipelineRequest) -> tuple[bool, Optional[str]]:
        """
        Validate pipeline request before execution.
        
        Args:
            request: Pipeline request to validate
            
        Returns:
            Tuple of (is_valid, error_message)
        """
        # Check required fields
        if not request.user_id:
            return False, "user_id is required"
        
        if request.bmr <= 0:
            return False, "bmr must be positive"
        
        if request.tdee <= 0:
            return False, "tdee must be positive"
        
        if request.weight_kg <= 0:
            return False, "weight_kg must be positive"
        
        if request.height_cm <= 0:
            return False, "height_cm must be positive"
        
        if request.age <= 0 or request.age > 120:
            return False, "age must be between 1 and 120"
        
        # All validations passed
        return True, None


# Singleton instance
_pipeline_service: Optional[MealPlanPipelineService] = None


def get_pipeline_service() -> MealPlanPipelineService:
    """
    Get singleton instance of pipeline service.
    
    Returns:
        MealPlanPipelineService instance
    """
    global _pipeline_service
    
    if _pipeline_service is None:
        _pipeline_service = MealPlanPipelineService()
    
    return _pipeline_service
