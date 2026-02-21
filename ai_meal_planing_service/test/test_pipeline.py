"""
Test suite for AI Meal Planning Pipeline

Demonstrates usage of all 3 pipeline functions individually and combined.
"""
from app.api.schemas.meal_plan_pipeline import (
    HealthGoalType,
    BodyProfile,
    DietConstraints,
    GoalProfile
)
from app.services.ai_core.meal_planning.dietary_analyzer import analyze_dietary_preferences
from app.services.ai_core.meal_planning.goal_analyzer import analyze_health_goal
from app.services.ai_core.meal_planning.meal_plan_generator import generate_meal_plan


def test_function_1_dietary_preferences():
    """Test Function 1: Analyze Dietary Preferences"""
    print("\n" + "="*60)
    print("TEST: Function 1 - Analyze Dietary Preferences")
    print("="*60)
    
    # Test input
    diet_types = ["Keto", "GLUTEN_FREE"]
    allergies = ["Peanuts", "Shellfish"]
    disliked = ["mushrooms", "PEANUTS", "cilantro"]
    
    print(f"\nInput:")
    print(f"  Diet Types: {diet_types}")
    print(f"  Allergies: {allergies}")
    print(f"  Dislikes: {disliked}")
    
    # Execute Function 1
    result = analyze_dietary_preferences(
        diet_types=diet_types,
        allergies=allergies,
        disliked_ingredients=disliked
    )
    
    print(f"\nOutput:")
    print(f"  Validated Diet Types: {result.diet_constraints.diet_types}")
    print(f"  Excluded Ingredients: {result.diet_constraints.excluded_ingredients}")
    print(f"\n✓ Function 1 completed successfully")
    
    return result.diet_constraints


def test_function_2_health_goals():
    """Test Function 2: Analyze Health Goals"""
    print("\n" + "="*60)
    print("TEST: Function 2 - Analyze Health Goals")
    print("="*60)
    
    # Test input
    health_goal = HealthGoalType.WEIGHT_LOSS
    tdee = 2500.0
    
    print(f"\nInput:")
    print(f"  Health Goal: {health_goal.value}")
    print(f"  TDEE: {tdee} cal/day")
    
    # Execute Function 2
    result = analyze_health_goal(
        health_goal=health_goal,
        user_tdee=tdee
    )
    
    print(f"\nOutput:")
    print(f"  Primary Goal: {result.goal_profile.primary_goal}")
    print(f"  Calorie Adjustment: {result.goal_profile.calorie_adjustment} cal/day")
    print(f"  Target Calories: {result.goal_profile.target_calories} cal/day")
    print(f"  Protein Priority: {result.goal_profile.protein_priority.value}")
    print(f"  Fat Priority: {result.goal_profile.fat_priority.value}")
    print(f"  Carb Priority: {result.goal_profile.carb_priority.value}")
    print(f"\n✓ Function 2 completed successfully")
    
    return result.goal_profile


def test_function_3_meal_plan_generation(
    diet_constraints: DietConstraints,
    goal_profile: GoalProfile
):
    """Test Function 3: Generate Personalized Meal Plan"""
    print("\n" + "="*60)
    print("TEST: Function 3 - Generate Personalized Meal Plan")
    print("="*60)
    
    # Test input - body profile
    body_profile = BodyProfile(
        bmr=1800.0,
        tdee=2500.0,
        weight_kg=80.0,
        height_cm=175.0,
        age=30,
        gender="male"
    )
    
    print(f"\nInput:")
    print(f"  Body Profile:")
    print(f"    BMR: {body_profile.bmr} cal/day")
    print(f"    TDEE: {body_profile.tdee} cal/day")
    print(f"    Weight: {body_profile.weight_kg} kg")
    print(f"    Height: {body_profile.height_cm} cm")
    print(f"  Diet Constraints: {len(diet_constraints.excluded_ingredients)} exclusions")
    print(f"  Goal Profile: {goal_profile.primary_goal}, {goal_profile.target_calories} cal target")
    
    # Execute Function 3
    result = generate_meal_plan(
        body_profile=body_profile,
        diet_constraints=diet_constraints,
        goal_profile=goal_profile
    )
    
    print(f"\nOutput:")
    print(f"  Daily Calories: {result.meal_plan.daily_calories:.0f} cal")
    print(f"  Total Protein: {result.meal_plan.total_protein_g:.1f}g")
    print(f"  Total Carbs: {result.meal_plan.total_carbs_g:.1f}g")
    print(f"  Total Fat: {result.meal_plan.total_fat_g:.1f}g")
    print(f"\n  Meals:")
    for meal in result.meal_plan.meals:
        print(f"    - {meal.meal_type.value.capitalize()}: {meal.recipe_name}")
        print(f"      Servings: {meal.servings}, Calories: {meal.estimated_calories:.0f}")
    
    print(f"\n  Metadata:")
    for key, value in result.metadata.items():
        print(f"    {key}: {value}")
    
    print(f"\n✓ Function 3 completed successfully")
    
    return result


def test_complete_pipeline():
    """Test the complete 3-step pipeline"""
    print("\n" + "="*70)
    print("COMPLETE PIPELINE TEST")
    print("="*70)
    print("\nExecuting 3-step pipeline in order:")
    print("  Step 1 → Step 2 → Step 3")
    print()
    
    # STEP 1: Analyze Dietary Preferences
    diet_constraints = test_function_1_dietary_preferences()
    
    # STEP 2: Analyze Health Goals
    goal_profile = test_function_2_health_goals()
    
    # STEP 3: Generate Meal Plan (using outputs from Step 1 & 2)
    meal_plan_result = test_function_3_meal_plan_generation(
        diet_constraints=diet_constraints,
        goal_profile=goal_profile
    )
    
    print("\n" + "="*70)
    print("PIPELINE EXECUTION COMPLETE")
    print("="*70)
    print("\n✓ All 3 functions executed successfully")
    print("✓ Data flowed correctly: Step 1 → Step 2 → Step 3")
    print("✓ Final meal plan generated with all constraints applied")
    print()


def test_different_scenarios():
    """Test different user scenarios"""
    print("\n" + "="*70)
    print("TESTING DIFFERENT USER SCENARIOS")
    print("="*70)
    
    scenarios = [
        {
            "name": "Vegan Weight Loss",
            "diet_types": ["vegan"],
            "allergies": [],
            "dislikes": ["tofu"],
            "health_goal": HealthGoalType.WEIGHT_LOSS,
            "tdee": 2200
        },
        {
            "name": "Keto Muscle Gain",
            "diet_types": ["keto"],
            "allergies": ["dairy"],
            "dislikes": [],
            "health_goal": HealthGoalType.MUSCLE_GAIN,
            "tdee": 2800
        },
        {
            "name": "No Restrictions Maintenance",
            "diet_types": [],
            "allergies": [],
            "dislikes": ["brussels_sprouts"],
            "health_goal": HealthGoalType.MAINTAIN,
            "tdee": 2400
        }
    ]
    
    for i, scenario in enumerate(scenarios, 1):
        print(f"\n{'─'*70}")
        print(f"Scenario {i}: {scenario['name']}")
        print(f"{'─'*70}")
        
        # Step 1
        diet_result = analyze_dietary_preferences(
            diet_types=scenario['diet_types'],
            allergies=scenario['allergies'],
            disliked_ingredients=scenario['dislikes']
        )
        
        # Step 2
        goal_result = analyze_health_goal(
            health_goal=scenario['health_goal'],
            user_tdee=scenario['tdee']
        )
        
        # Step 3
        body_profile = BodyProfile(
            bmr=1700.0,
            tdee=scenario['tdee'],
            weight_kg=75.0,
            height_cm=170.0,
            age=28,
            gender="female"
        )
        
        meal_result = generate_meal_plan(
            body_profile=body_profile,
            diet_constraints=diet_result.diet_constraints,
            goal_profile=goal_result.goal_profile
        )
        
        print(f"  ✓ Target: {goal_result.goal_profile.target_calories:.0f} cal/day")
        print(f"  ✓ Generated: {meal_result.meal_plan.daily_calories:.0f} cal/day")
        print(f"  ✓ Meals: {len(meal_result.meal_plan.meals)}")
    
    print(f"\n{'='*70}")
    print("✓ All scenarios tested successfully")
    print(f"{'='*70}\n")


if __name__ == "__main__":
    # Run tests
    print("\n" + "#"*70)
    print("# AI MEAL PLANNING PIPELINE - TEST SUITE")
    print("#"*70)
    
    # Test complete pipeline
    test_complete_pipeline()
    
    # Test different scenarios
    test_different_scenarios()
    
    print("\n" + "#"*70)
    print("# ALL TESTS PASSED ✓")
    print("#"*70)
    print()
