"""
User endpoints for profile analysis and management.
"""
from fastapi import APIRouter, HTTPException, status

from app.schemas.user import UserProfile, UserProfileAnalysis
from app.services.user_service import user_service

router = APIRouter()


@router.post(
    "/analyze",
    response_model=UserProfileAnalysis,
    status_code=status.HTTP_200_OK,
)
async def analyze_user_profile(profile: UserProfile):
    """
    Analyze user profile and calculate nutritional requirements.

    This endpoint takes user health data, preferences, and goals,
    then returns a comprehensive analysis including:
    - BMR and TDEE calculations
    - Recommended daily calories
    - Dietary recommendations
    - Health priorities

    Args:
        profile: User profile data

    Returns:
        Complete profile analysis with metabolic calculations
    """
    try:
        analysis = user_service.analyze_user_profile(profile)
        return analysis
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e),
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error analyzing profile: {str(e)}",
        )


@router.post("/validate")
async def validate_profile(profile: UserProfile):
    """
    Validate user profile data without full analysis.

    Useful for form validation before submission.
    """
    return {
        "valid": True,
        "user_id": profile.user_id,
        "message": "Profile data is valid",
    }
