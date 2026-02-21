from fastapi import APIRouter, HTTPException, status
from app.api.schemas.user_analysis import UserProfileRequest, UserProfileAnalysisResponse
from app.domain.models.user_profile import UserProfile
from app.services.ai_core.nutrition.bmr_tdee_calculator import analyze_user_profile
import logging

logger = logging.getLogger(__name__)

router = APIRouter()


@router.post(
    "/analyze",
    response_model=UserProfileAnalysisResponse,
    summary="Analyze User Profile",
    status_code=status.HTTP_200_OK,
)
async def analyze_user_profile_endpoint(
    payload: UserProfileRequest,
):
    """
    Analyze user profile and calculate health metrics.
    
    This endpoint receives user profile data from the Node.js backend and:
    - Calculates BMR (Basal Metabolic Rate)
    - Calculates TDEE (Total Daily Energy Expenditure)
    - Calculates target calories based on health goals
    - Determines BMI and body category
    - Provides personalized recommendations
    
    The backend should save these results to the database.
    
    **Sequence:**
    1. Backend loads user profile + health data from DB
    2. Backend calls this endpoint with profile data
    3. AI Core calculates BMR, TDEE, metabolic metrics
    4. Returns structured analysis result
    5. Backend saves analysis result to DB
    """
    try:
        logger.info(f"Analyzing profile for user {payload.user_id}")
        
        # Convert request payload to UserProfile domain model
        user_profile = UserProfile(
            user_id=payload.user_id,
            age=payload.age,
            gender=payload.gender,
            height_cm=payload.height_cm,
            weight_kg=payload.weight_kg,
            goal_weight_kg=payload.goal_weight_kg,
            health_goals=payload.health_goals,
            activity_level=payload.activity_level,
        )
        
        # Validate activity level
        valid_activity_levels = ["sedentary", "light", "moderate", "active", "very_active"]
        if user_profile.activity_level.lower() not in valid_activity_levels:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Invalid activity level. Must be one of: {', '.join(valid_activity_levels)}"
            )
        
        # Validate gender
        valid_genders = ["male", "female", "other"]
        if user_profile.gender.lower() not in valid_genders:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Invalid gender. Must be one of: {', '.join(valid_genders)}"
            )
        
        # Call AI Core service to analyze profile
        # This uses the Rule Engine / ML to calculate metrics
        analysis_result = analyze_user_profile(
            user=user_profile,
            health_goals=[payload.health_goals]
        )
        
        # Convert HealthMetrics domain model to HealthMetricsResponse schema
        health_metrics_dict = analysis_result["health_metrics"].model_dump()
        
        # Transform to response schema
        response = UserProfileAnalysisResponse(
            user_id=analysis_result["user_id"],
            health_metrics=health_metrics_dict,
            bmi=analysis_result["bmi"],
            bmi_category=analysis_result["bmi_category"],
            primary_health_goal=analysis_result["primary_health_goal"],
            activity_level=analysis_result["activity_level"],
            analysis_summary=analysis_result["analysis_summary"],
            source="AI"
        )
        
        logger.info(f"Profile analysis completed for user {payload.user_id}: BMR={response.health_metrics.bmr}, TDEE={response.health_metrics.tdee}, BMI={response.bmi}")
        return response
        
    except HTTPException:
        raise
    except ValueError as e:
        logger.error(f"Validation error for user {payload.user_id}: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        logger.error(f"Error analyzing profile for user {payload.user_id}: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to analyze user profile: {str(e)}"
        )
