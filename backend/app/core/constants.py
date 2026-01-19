"""
Application constants and enums.
"""
from enum import Enum


class Gender(str, Enum):
    """Gender enumeration for BMR calculations."""
    MALE = "male"
    FEMALE = "female"


class ActivityLevel(str, Enum):
    """Activity level for TDEE calculations."""
    SEDENTARY = "sedentary"  # Little or no exercise
    LIGHTLY_ACTIVE = "lightly_active"  # Light exercise 1-3 days/week
    MODERATELY_ACTIVE = "moderately_active"  # Moderate exercise 3-5 days/week
    VERY_ACTIVE = "very_active"  # Hard exercise 6-7 days/week
    EXTRA_ACTIVE = "extra_active"  # Very hard exercise, physical job


# Activity level multipliers for TDEE calculation
ACTIVITY_MULTIPLIERS = {
    ActivityLevel.SEDENTARY: 1.2,
    ActivityLevel.LIGHTLY_ACTIVE: 1.375,
    ActivityLevel.MODERATELY_ACTIVE: 1.55,
    ActivityLevel.VERY_ACTIVE: 1.725,
    ActivityLevel.EXTRA_ACTIVE: 1.9,
}


class DietType(str, Enum):
    """Diet type preferences."""
    STANDARD = "standard"
    VEGETARIAN = "vegetarian"
    VEGAN = "vegan"
    KETO = "keto"
    PALEO = "paleo"
    MEDITERRANEAN = "mediterranean"
    LOW_CARB = "low_carb"
    HIGH_PROTEIN = "high_protein"


class HealthGoal(str, Enum):
    """Health and fitness goals."""
    WEIGHT_LOSS = "weight_loss"
    WEIGHT_GAIN = "weight_gain"
    MAINTENANCE = "maintenance"
    MUSCLE_GAIN = "muscle_gain"
    IMPROVE_HEALTH = "improve_health"


class MealType(str, Enum):
    """Types of meals."""
    BREAKFAST = "breakfast"
    LUNCH = "lunch"
    DINNER = "dinner"
    SNACK = "snack"


# Default macro distribution ratios
DEFAULT_MACRO_RATIOS = {
    "protein": 0.25,  # 25% of calories
    "carbohydrates": 0.50,  # 50% of calories
    "fat": 0.25,  # 25% of calories
}

# Macro ratios by diet type
DIET_MACRO_RATIOS = {
    DietType.STANDARD: {"protein": 0.25, "carbohydrates": 0.50, "fat": 0.25},
    DietType.KETO: {"protein": 0.20, "carbohydrates": 0.05, "fat": 0.75},
    DietType.LOW_CARB: {"protein": 0.30, "carbohydrates": 0.20, "fat": 0.50},
    DietType.HIGH_PROTEIN: {"protein": 0.40, "carbohydrates": 0.35, "fat": 0.25},
    DietType.VEGETARIAN: {"protein": 0.20, "carbohydrates": 0.55, "fat": 0.25},
    DietType.VEGAN: {"protein": 0.20, "carbohydrates": 0.55, "fat": 0.25},
    DietType.PALEO: {"protein": 0.30, "carbohydrates": 0.30, "fat": 0.40},
    DietType.MEDITERRANEAN: {"protein": 0.20, "carbohydrates": 0.45, "fat": 0.35},
}

# Calorie adjustment for goals
GOAL_CALORIE_ADJUSTMENTS = {
    HealthGoal.WEIGHT_LOSS: -500,  # 500 calorie deficit
    HealthGoal.WEIGHT_GAIN: 500,  # 500 calorie surplus
    HealthGoal.MAINTENANCE: 0,
    HealthGoal.MUSCLE_GAIN: 300,  # Moderate surplus for muscle
    HealthGoal.IMPROVE_HEALTH: 0,
}

# Meal calorie distribution
MEAL_CALORIE_DISTRIBUTION = {
    MealType.BREAKFAST: 0.25,
    MealType.LUNCH: 0.35,
    MealType.DINNER: 0.30,
    MealType.SNACK: 0.10,
}
