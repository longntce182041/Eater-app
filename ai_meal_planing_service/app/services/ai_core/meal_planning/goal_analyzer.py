"""
Function 2: Analyze Health Goals

This module interprets the user's health objective and converts it into
numeric nutrition targets that guide meal plan generation.

Rules:
- Deterministic (no random behavior)
- Does NOT generate meals
- Converts goals to calorie/macro strategies
- Safe bounds for extreme cases
"""
from typing import Optional
from app.api.schemas.meal_plan_pipeline import (
    HealthGoalInput,
    HealthGoalOutput,
    GoalProfile,
    HealthGoalType,
    MacroPriority
)
import logging

logger = logging.getLogger(__name__)

# Safe calorie adjustment bounds
MIN_SAFE_CALORIE_ADJUSTMENT = -1000  # Maximum deficit per day
MAX_SAFE_CALORIE_ADJUSTMENT = 1000   # Maximum surplus per day

# Minimum safe daily calories
MIN_SAFE_DAILY_CALORIES = 1200  # For most adults


class HealthGoalAnalyzer:
    """
    Analyzes health goals and produces goal profile with calorie/macro strategy.
    
    This is a pure function class - stateless and deterministic.
    """
    
    def __init__(self):
        """Initialize the goal analyzer"""
        pass
    
    def analyze(
        self,
        health_goal: HealthGoalType,
        user_tdee: Optional[float] = None,
        target_weight: Optional[float] = None,
        timeline_weeks: Optional[int] = None
    ) -> HealthGoalOutput:
        """
        Analyze health goal and produce goal profile.
        
        Processing Flow:
        1. Map health goal to base calorie adjustment
        2. If TDEE provided, compute target calories
        3. Apply safe bounds
        4. Determine macro priorities
        5. Return goal profile
        
        Args:
            health_goal: Primary health objective
            user_tdee: User's Total Daily Energy Expenditure (optional)
            target_weight: Target weight in kg (optional)
            timeline_weeks: Timeline to achieve goal (optional)
            
        Returns:
            HealthGoalOutput with computed goal profile
            
        Example:
            >>> analyzer = HealthGoalAnalyzer()
            >>> result = analyzer.analyze(
            ...     health_goal=HealthGoalType.WEIGHT_LOSS,
            ...     user_tdee=2500
            ... )
            >>> result.goal_profile.calorie_adjustment
            -500
            >>> result.goal_profile.target_calories
            2000
        """
        logger.info(f"Analyzing health goal: {health_goal}, TDEE: {user_tdee}")
        
        # Step 1: Get base calorie adjustment for goal
        calorie_adjustment = self._get_calorie_adjustment(health_goal)
        
        # Step 2: Apply safe bounds
        calorie_adjustment = self._apply_safe_bounds(calorie_adjustment)
        
        # Step 3: Calculate target calories if TDEE provided
        target_calories = None
        if user_tdee is not None:
            target_calories = user_tdee + calorie_adjustment
            # Ensure minimum safe intake
            target_calories = max(target_calories, MIN_SAFE_DAILY_CALORIES)
        
        # Step 4: Determine macro priorities based on goal
        protein_priority, fat_priority, carb_priority = self._get_macro_priorities(health_goal)
        
        # Step 5: Build goal profile
        goal_profile = GoalProfile(
            primary_goal=health_goal.value,
            calorie_adjustment=calorie_adjustment,
            target_calories=target_calories,
            protein_priority=protein_priority,
            fat_priority=fat_priority,
            carb_priority=carb_priority
        )
        
        logger.info(f"Goal profile created: adjustment={calorie_adjustment}, "
                   f"target={target_calories}, protein={protein_priority}")
        
        return HealthGoalOutput(goal_profile=goal_profile)
    
    def _get_calorie_adjustment(self, health_goal: HealthGoalType) -> float:
        """
        Map health goal to base calorie adjustment.
        
        Calorie adjustments based on evidence-based practices:
        - 3500 calories ≈ 1 lb of body weight
        - Safe weight loss: 1-2 lbs/week = 500-1000 cal deficit/day
        - Safe weight gain: 0.5-1 lb/week = 250-500 cal surplus/day
        
        Args:
            health_goal: Health objective
            
        Returns:
            Daily calorie adjustment (negative=deficit, positive=surplus)
        """
        adjustment_map = {
            HealthGoalType.WEIGHT_LOSS: -500,              # 1 lb/week loss
            HealthGoalType.AGGRESSIVE_WEIGHT_LOSS: -750,   # 1.5 lbs/week loss
            HealthGoalType.MUSCLE_GAIN: 300,               # Lean muscle gain
            HealthGoalType.MAINTAIN: 0                     # Maintenance
        }
        
        return adjustment_map.get(health_goal, 0)
    
    def _apply_safe_bounds(self, calorie_adjustment: float) -> float:
        """
        Apply safety bounds to calorie adjustment.
        
        Args:
            calorie_adjustment: Raw calorie adjustment
            
        Returns:
            Bounded calorie adjustment within safe limits
        """
        # Clamp to safe bounds
        if calorie_adjustment < MIN_SAFE_CALORIE_ADJUSTMENT:
            logger.warning(f"Calorie adjustment {calorie_adjustment} too low, "
                         f"clamping to {MIN_SAFE_CALORIE_ADJUSTMENT}")
            return MIN_SAFE_CALORIE_ADJUSTMENT
        
        if calorie_adjustment > MAX_SAFE_CALORIE_ADJUSTMENT:
            logger.warning(f"Calorie adjustment {calorie_adjustment} too high, "
                         f"clamping to {MAX_SAFE_CALORIE_ADJUSTMENT}")
            return MAX_SAFE_CALORIE_ADJUSTMENT
        
        return calorie_adjustment
    
    def _get_macro_priorities(
        self,
        health_goal: HealthGoalType
    ) -> tuple[MacroPriority, MacroPriority, MacroPriority]:
        """
        Determine macro nutrient priorities based on health goal.
        
        Returns tuple of (protein_priority, fat_priority, carb_priority)
        
        Macro strategy rationale:
        - Weight Loss: High protein (satiety + muscle preservation), 
                      moderate fat, low-medium carb
        - Muscle Gain: High protein (muscle building), 
                      medium fat, high carb (energy)
        - Maintain: Balanced approach
        
        Args:
            health_goal: Health objective
            
        Returns:
            Tuple of (protein, fat, carb) priorities
        """
        priority_map = {
            HealthGoalType.WEIGHT_LOSS: (
                MacroPriority.HIGH,    # Protein: preserve muscle
                MacroPriority.MEDIUM,  # Fat: hormones & satiety
                MacroPriority.MEDIUM   # Carbs: moderate for energy
            ),
            HealthGoalType.AGGRESSIVE_WEIGHT_LOSS: (
                MacroPriority.HIGH,    # Protein: critical for muscle preservation
                MacroPriority.LOW,     # Fat: minimize for deficit
                MacroPriority.LOW      # Carbs: minimize for deficit
            ),
            HealthGoalType.MUSCLE_GAIN: (
                MacroPriority.HIGH,    # Protein: muscle building
                MacroPriority.MEDIUM,  # Fat: hormones
                MacroPriority.HIGH     # Carbs: energy for workouts
            ),
            HealthGoalType.MAINTAIN: (
                MacroPriority.MEDIUM,  # Protein: balanced
                MacroPriority.MEDIUM,  # Fat: balanced
                MacroPriority.MEDIUM   # Carbs: balanced
            )
        }
        
        return priority_map.get(
            health_goal,
            (MacroPriority.MEDIUM, MacroPriority.MEDIUM, MacroPriority.MEDIUM)
        )


# Convenience function for direct use
def analyze_health_goal(
    health_goal: HealthGoalType,
    user_tdee: Optional[float] = None,
    target_weight: Optional[float] = None,
    timeline_weeks: Optional[int] = None
) -> HealthGoalOutput:
    """
    Convenience function to analyze health goal.
    
    This is the main entry point for Function 2.
    
    Args:
        health_goal: Health objective
        user_tdee: User's TDEE (optional)
        target_weight: Target weight (optional)
        timeline_weeks: Timeline (optional)
        
    Returns:
        HealthGoalOutput with goal profile
    """
    analyzer = HealthGoalAnalyzer()
    return analyzer.analyze(health_goal, user_tdee, target_weight, timeline_weeks)
