# File: d:\SP26\WDP\code base\Eater-app\ai_meal_planing_service\app\services\ai_core\nutrition\targets.py

from typing import Dict
from app.domain.models.health_metrics import HealthMetrics


def calculate_macro_targets(
    target_calories: float, 
    dietary_style: str = "balanced"
) -> Dict[str, float]:
    """
    Calculate macronutrient targets based on dietary style.
    
    Macro splits by dietary style:
    - balanced: 30% protein, 40% carbs, 30% fat
    - keto: 25% protein, 5% carbs, 70% fat
    - high_protein: 40% protein, 30% carbs, 30% fat
    - low_fat: 30% protein, 50% carbs, 20% fat
    - mediterranean: 20% protein, 45% carbs, 35% fat
    - vegan: 20% protein, 50% carbs, 30% fat
    
    Args:
        target_calories: Daily calorie target
        dietary_style: User's dietary preference
        
    Returns:
        Dict with protein_g, carbs_g, fat_g
    """
    # Macro splits as percentages
    macro_splits = {
        "balanced": {"protein": 0.30, "carbs": 0.40, "fat": 0.30},
        "keto": {"protein": 0.25, "carbs": 0.05, "fat": 0.70},
        "high_protein": {"protein": 0.40, "carbs": 0.30, "fat": 0.30},
        "low_fat": {"protein": 0.30, "carbs": 0.50, "fat": 0.20},
        "mediterranean": {"protein": 0.20, "carbs": 0.45, "fat": 0.35},
        "vegan": {"protein": 0.20, "carbs": 0.50, "fat": 0.30},
        "vegetarian": {"protein": 0.25, "carbs": 0.45, "fat": 0.30},
        "paleo": {"protein": 0.35, "carbs": 0.25, "fat": 0.40},
    }
    
    style_key = dietary_style.lower().replace(" ", "_")
    split = macro_splits.get(style_key, macro_splits["balanced"])
    
    # Calories per gram: protein=4, carbs=4, fat=9
    protein_calories = target_calories * split["protein"]
    carbs_calories = target_calories * split["carbs"]
    fat_calories = target_calories * split["fat"]
    
    return {
        "protein_g": round(protein_calories / 4, 2),
        "carbs_g": round(carbs_calories / 4, 2),
        "fat_g": round(fat_calories / 9, 2),
        "protein_percent": split["protein"] * 100,
        "carbs_percent": split["carbs"] * 100,
        "fat_percent": split["fat"] * 100,
    }


def calculate_micronutrient_targets(
    age: int,
    gender: str,
    health_goals: list[str] = None
) -> Dict[str, float]:
    """
    Calculate daily micronutrient targets based on RDA (Recommended Dietary Allowance).
    
    Args:
        age: User's age
        gender: User's gender
        health_goals: List of health goals for adjustments
        
    Returns:
        Dict with micronutrient targets in appropriate units
    """
    # Base RDA values (simplified)
    if gender.lower() == "male":
        base_targets = {
            "vitamin_a_mcg": 900,
            "vitamin_c_mg": 90,
            "vitamin_d_mcg": 15,
            "vitamin_e_mg": 15,
            "calcium_mg": 1000 if age < 70 else 1200,
            "iron_mg": 8,
            "magnesium_mg": 400 if age < 30 else 420,
            "potassium_mg": 3400,
            "sodium_mg": 2300,  # Upper limit
            "fiber_g": 38 if age < 50 else 30,
        }
    else:  # female or other
        base_targets = {
            "vitamin_a_mcg": 700,
            "vitamin_c_mg": 75,
            "vitamin_d_mcg": 15,
            "vitamin_e_mg": 15,
            "calcium_mg": 1000 if age < 50 else 1200,
            "iron_mg": 18 if age < 50 else 8,
            "magnesium_mg": 310 if age < 30 else 320,
            "potassium_mg": 2600,
            "sodium_mg": 2300,  # Upper limit
            "fiber_g": 25 if age < 50 else 21,
        }
    
    # Adjust based on health goals
    if health_goals:
        for goal in health_goals:
            if "bone_health" in goal.lower():
                base_targets["calcium_mg"] *= 1.2
                base_targets["vitamin_d_mcg"] *= 1.3
            elif "immune" in goal.lower():
                base_targets["vitamin_c_mg"] *= 1.2
                base_targets["vitamin_d_mcg"] *= 1.2
            elif "muscle" in goal.lower():
                base_targets["magnesium_mg"] *= 1.1
    
    return {k: round(v, 2) for k, v in base_targets.items()}


def calculate_meal_distribution(
    target_calories: float,
    num_meals: int = 3,
    include_snacks: bool = False
) -> Dict[str, float]:
    """
    Distribute daily calories across meals.
    
    Args:
        target_calories: Total daily calorie target
        num_meals: Number of main meals (default: 3)
        include_snacks: Whether to include snack calories
        
    Returns:
        Dict with calorie distribution per meal type
    """
    if include_snacks:
        # Reserve 15% for snacks
        snack_calories = target_calories * 0.15
        meal_calories = target_calories - snack_calories
    else:
        snack_calories = 0
        meal_calories = target_calories
    
    if num_meals == 3:
        # Breakfast: 25%, Lunch: 40%, Dinner: 35%
        distribution = {
            "breakfast": meal_calories * 0.25,
            "lunch": meal_calories * 0.40,
            "dinner": meal_calories * 0.35,
        }
    elif num_meals == 2:
        # Lunch: 50%, Dinner: 50%
        distribution = {
            "lunch": meal_calories * 0.50,
            "dinner": meal_calories * 0.50,
        }
    else:
        # Equal distribution
        per_meal = meal_calories / num_meals
        distribution = {f"meal_{i+1}": per_meal for i in range(num_meals)}
    
    if include_snacks:
        distribution["snacks"] = snack_calories
    
    return {k: round(v, 2) for k, v in distribution.items()}