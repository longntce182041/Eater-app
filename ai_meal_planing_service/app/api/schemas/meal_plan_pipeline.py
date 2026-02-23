"""
Pydantic schemas for the AI Meal Planning Pipeline
"""
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from enum import Enum


# ============================================================================
# ENUMS
# ============================================================================

class HealthGoalType(str, Enum):
    """Supported health goals"""
    WEIGHT_LOSS = "weight_loss"
    MUSCLE_GAIN = "muscle_gain"
    MAINTAIN = "maintain"
    AGGRESSIVE_WEIGHT_LOSS = "aggressive_weight_loss"


class MacroPriority(str, Enum):
    """Macro nutrient priority levels"""
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"


class MealType(str, Enum):
    """Types of meals in a day"""
    BREAKFAST = "breakfast"
    LUNCH = "lunch"
    DINNER = "dinner"
    SNACK = "snack"


# ============================================================================
# FUNCTION 1: ANALYZE DIETARY PREFERENCES - INPUT/OUTPUT
# ============================================================================

class DietaryPreferencesInput(BaseModel):
    """Input for dietary preferences analysis"""
    diet_types: List[str] = Field(
        default_factory=list,
        description="List of diet types (e.g., ['keto', 'vegan'])"
    )
    allergies: List[str] = Field(
        default_factory=list,
        description="List of allergen ingredients"
    )
    disliked_ingredients: List[str] = Field(
        default_factory=list,
        description="List of disliked ingredients"
    )


class DietConstraints(BaseModel):
    """Normalized diet constraints from dietary preferences analysis"""
    diet_types: List[str] = Field(
        default_factory=list,
        description="Validated diet types"
    )
    excluded_ingredients: List[str] = Field(
        default_factory=list,
        description="Combined allergies and dislikes (normalized)"
    )


class DietaryPreferencesOutput(BaseModel):
    """Output from dietary preferences analysis"""
    diet_constraints: DietConstraints = Field(
        ...,
        description="Normalized diet constraints for meal planning"
    )


# ============================================================================
# FUNCTION 2: ANALYZE HEALTH GOALS - INPUT/OUTPUT
# ============================================================================

class HealthGoalInput(BaseModel):
    """Input for health goals analysis"""
    health_goal: HealthGoalType = Field(
        ...,
        description="Primary health objective"
    )
    target_weight: Optional[float] = Field(
        None,
        gt=0,
        description="Target weight in kg (optional)"
    )
    timeline_weeks: Optional[int] = Field(
        None,
        description="Timeline to achieve goal in weeks (optional, 1-52 weeks if provided)"
    )
    user_tdee: Optional[float] = Field(
        None,
        gt=0,
        description="User's Total Daily Energy Expenditure (optional but preferred)"
    )


class GoalProfile(BaseModel):
    """Goal profile with calorie and macro strategy"""
    primary_goal: str = Field(
        ...,
        description="Primary health goal"
    )
    calorie_adjustment: float = Field(
        ...,
        description="Daily calorie adjustment from TDEE (negative=deficit, positive=surplus)"
    )
    target_calories: Optional[float] = Field(
        None,
        description="Target daily calories (if TDEE provided)"
    )
    protein_priority: MacroPriority = Field(
        ...,
        description="Protein intake priority level"
    )
    fat_priority: MacroPriority = Field(
        ...,
        description="Fat intake priority level"
    )
    carb_priority: MacroPriority = Field(
        ...,
        description="Carbohydrate intake priority level"
    )


class HealthGoalOutput(BaseModel):
    """Output from health goals analysis"""
    goal_profile: GoalProfile = Field(
        ...,
        description="Computed goal profile for meal planning"
    )


# ============================================================================
# FUNCTION 3: GENERATE MEAL PLAN - INPUT/OUTPUT
# ============================================================================

class BodyProfile(BaseModel):
    """
    User's metabolic profile from upstream 'Analyze User Profile' function.
    
    This model matches the output of the existing analyzeUserProfile function.
    Do NOT recalculate BMR/TDEE if already provided - trust the upstream calculation.
    """
    age: int = Field(..., description="Age in years")
    gender: str = Field(..., description="Gender (male/female/other)")
    bmi: Optional[float] = Field(None, description="Body Mass Index (from upstream)")
    bmr: float = Field(..., description="Basal Metabolic Rate (calories/day)")
    tdee: float = Field(..., description="Total Daily Energy Expenditure (calories/day)")
    activity_level: Optional[str] = Field(None, description="Activity level (from upstream)")
    weight_kg: Optional[float] = Field(None, description="Current weight in kg")
    height_cm: Optional[float] = Field(None, description="Height in cm")


class MealItem(BaseModel):
    """Single meal in the plan"""
    meal_type: MealType = Field(..., description="Type of meal")
    recipe_id: str = Field(..., description="Recipe identifier")
    recipe_name: Optional[str] = Field(None, description="Recipe name")
    servings: float = Field(..., gt=0, description="Number of servings")
    estimated_calories: float = Field(..., description="Estimated calories for this meal")
    protein_g: Optional[float] = Field(None, description="Protein in grams")
    carbs_g: Optional[float] = Field(None, description="Carbohydrates in grams")
    fat_g: Optional[float] = Field(None, description="Fat in grams")


class MealPlan(BaseModel):
    """Generated meal plan"""
    daily_calories: float = Field(..., description="Total daily calories")
    meals: List[MealItem] = Field(..., description="List of meals in the plan")
    total_protein_g: Optional[float] = Field(None, description="Total daily protein")
    total_carbs_g: Optional[float] = Field(None, description="Total daily carbs")
    total_fat_g: Optional[float] = Field(None, description="Total daily fat")


class MealPlanGenerationInput(BaseModel):
    """Input for meal plan generation (Core function)"""
    body_profile: BodyProfile = Field(..., description="User's metabolic data")
    diet_constraints: DietConstraints = Field(..., description="Diet constraints from Function 1")
    goal_profile: GoalProfile = Field(..., description="Goal profile from Function 2")
    days: int = Field(default=1, ge=1, le=7, description="Number of days to generate")


class MealPlanGenerationOutput(BaseModel):
    """Output from meal plan generation"""
    meal_plan: MealPlan = Field(..., description="Generated personalized meal plan")
    metadata: Dict[str, Any] = Field(
        default_factory=dict,
        description="Additional metadata about generation"
    )


# ============================================================================
# COMPLETE PIPELINE - INPUT/OUTPUT
# ============================================================================

class MealPlanPipelineRequest(BaseModel):
    """
    Complete pipeline request combining all inputs.
    
    INTEGRATION WITH UPSTREAM:
    - Accepts body_profile directly from 'Analyze User Profile' function
    - Individual fields (bmr, tdee, etc.) are optional fallback
    - Prefer using body_profile when available (already calculated upstream)
    """
    # User profile
    user_id: str = Field(..., description="User identifier")
    
    # For Function 1: Dietary Preferences
    diet_types: List[str] = Field(default_factory=list, description="Diet types")
    allergies: List[str] = Field(default_factory=list, description="Allergies")
    disliked_ingredients: List[str] = Field(default_factory=list, description="Disliked ingredients")
    
    # For Function 2: Health Goals
    health_goal: HealthGoalType = Field(..., description="Health objective")
    target_weight: Optional[float] = Field(None, description="Target weight in kg (>0 if provided)")
    timeline_weeks: Optional[int] = Field(None, description="Timeline in weeks (1-52 if provided)")
    
    # For Function 3: Body Profile (UPSTREAM INTEGRATION)
    body_profile: Optional[BodyProfile] = Field(
        None,
        description="Body profile from upstream 'Analyze User Profile' function (PREFERRED)"
    )
    
    # Fallback: Individual body profile fields (if body_profile not provided)
    bmr: Optional[float] = Field(None, description="Basal Metabolic Rate (fallback)")
    tdee: Optional[float] = Field(None, description="Total Daily Energy Expenditure (fallback)")
    weight_kg: Optional[float] = Field(None, description="Current weight in kg (>0 if provided)")
    height_cm: Optional[float] = Field(None, description="Height in cm (>0 if provided)")
    age: Optional[int] = Field(None, description="Age in years (1-120 if provided)")
    gender: Optional[str] = Field(None, description="Gender (fallback)")
    activity_level: Optional[str] = Field(None, description="Activity level (fallback)")
    
    # Generation parameters
    days: int = Field(default=1, ge=1, le=7, description="Number of days")
    
    # Recipe database (optional - uses mock if not provided)
    recipe_database: Optional[List[Dict[str, Any]]] = Field(
        None,
        description="Custom recipe database from backend (optional, uses mock if not provided)"
    )


class MealPlanPipelineResponse(BaseModel):
    """Complete pipeline response"""
    user_id: str = Field(..., description="User identifier")
    
    # Step 1 output
    diet_constraints: DietConstraints = Field(..., description="Analyzed diet constraints")
    
    # Step 2 output
    goal_profile: GoalProfile = Field(..., description="Analyzed goal profile")
    
    # Step 3 output
    meal_plan: MealPlan = Field(..., description="Generated meal plan")
    
    # Metadata
    pipeline_metadata: Dict[str, Any] = Field(
        default_factory=dict,
        description="Pipeline execution metadata"
    )
