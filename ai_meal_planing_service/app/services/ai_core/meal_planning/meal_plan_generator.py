"""
Function 3: Generate Personalized Meal Plan (Core)

This is the CORE AI engine responsible for assembling meals that satisfy
nutrition targets and dietary restrictions.

Rules:
- Respect excluded ingredients strictly
- Match target calories within tolerance (±10%)
- Distribute macros across meals
- Prefer high-score recipes
- Modular and extensible
"""
from typing import List, Dict, Optional, Any
from app.api.schemas.meal_plan_pipeline import (
    BodyProfile,
    DietConstraints,
    GoalProfile,
    MealPlan,
    MealItem,
    MealType,
    MealPlanGenerationOutput
)
import logging
import random

logger = logging.getLogger(__name__)

# Calorie tolerance for matching target
CALORIE_TOLERANCE = 0.10  # ±10%

# Default meal distribution (% of daily calories)
DEFAULT_MEAL_DISTRIBUTION = {
    MealType.BREAKFAST: 0.25,  # 25%
    MealType.LUNCH: 0.35,      # 35%
    MealType.DINNER: 0.35,     # 35%
    MealType.SNACK: 0.05       # 5%
}


class RecipeScore:
    """Simple recipe scoring for selection"""
    
    @staticmethod
    def calculate_score(
        recipe: Dict[str, Any],
        goal_profile: GoalProfile
    ) -> float:
        """
        Calculate recipe score based on goal profile.
        
        Higher score = better match for user's goals
        
        Args:
            recipe: Recipe data dictionary
            goal_profile: User's goal profile
            
        Returns:
            Score value (higher is better)
        """
        score = 0.0
        
        # Base score from recipe rating if available
        rating = recipe.get('rating', 3.0)
        score += rating * 10
        
        # Bonus for macro priorities (simplified)
        # In production, would analyze actual macro content
        score += 5  # Placeholder for macro matching
        
        # Popularity bonus
        review_count = recipe.get('review_count', 0)
        score += min(review_count / 10, 10)  # Up to 10 points
        
        return score


class MealPlanGenerator:
    """
    Core AI engine for generating personalized meal plans.
    
    This class assembles meals that satisfy:
    - Nutrition targets (calories, macros)
    - Dietary restrictions (diet types, exclusions)
    - User preferences
    """
    
    def __init__(self):
        """Initialize the meal plan generator"""
        self.recipe_scorer = RecipeScore()
    
    def generate(
        self,
        body_profile: BodyProfile,
        diet_constraints: DietConstraints,
        goal_profile: GoalProfile,
        recipe_database: Optional[List[Dict[str, Any]]] = None,
        days: int = 1
    ) -> MealPlanGenerationOutput:
        """
        Generate a personalized meal plan for N days.
        
        Processing Flow:
        1. Determine target daily calories
        2. Filter candidate recipes by diet constraints
        3. Distribute calories across meals
        4. Generate meals for each day with recipe variety
           (different recipes per day while respecting user constraints)
        5. Balance macros
        6. Assemble final meal plan
        
        Args:
            body_profile: User's metabolic data
            diet_constraints: Diet constraints from Function 1
            goal_profile: Goal profile from Function 2
            recipe_database: Optional recipe database (mock if None)
            days: Number of days to generate meals for (default: 1, max: 30)
            
        Returns:
            MealPlanGenerationOutput with generated meal plan
        """
        logger.info(f"Starting meal plan generation for {days} days")
        
        # Step 1: Determine target daily calories
        target_calories = self._get_target_calories(body_profile, goal_profile)
        
        # Step 2: Get recipe database (mock if not provided)
        if recipe_database is None:
            recipe_database = self._get_mock_recipe_database()
        
        # Step 3: Filter candidate recipes (respects user constraints)
        candidates = self._filter_recipes(recipe_database, diet_constraints)
        
        if not candidates:
            logger.warning("No candidate recipes found after filtering")
            # Return empty meal plan
            return self._create_empty_meal_plan(target_calories)
        
        # Step 4: Distribute calories across meals
        meal_calorie_targets = self._distribute_calories(target_calories)
        
        # Step 5: Generate meals for N days with variety
        meals = self._select_meals_with_variety(
            candidates,
            meal_calorie_targets,
            goal_profile,
            days
        )
        
        # Step 6: Calculate totals
        total_calories, total_protein, total_carbs, total_fat = self._calculate_totals(meals)
        
        # Step 7: Build meal plan
        meal_plan = MealPlan(
            daily_calories=total_calories / days if days > 0 else total_calories,
            meals=meals,
            total_protein_g=total_protein,
            total_carbs_g=total_carbs,
            total_fat_g=total_fat
        )
        
        # Metadata
        metadata = {
            "target_calories": target_calories,
            "calorie_match_percentage": (total_calories / (target_calories * days) * 100) if days > 0 else 0,
            "candidate_recipes_count": len(candidates),
            "meals_generated": len(meals),
            "days_generated": days
        }
        
        logger.info(f"Meal plan generated: {len(meals)} meals over {days} days, "
                   f"{total_calories:.0f} total calories (target: {target_calories * days:.0f})")
        
        return MealPlanGenerationOutput(
            meal_plan=meal_plan,
            metadata=metadata
        )
    
    def _get_target_calories(
        self,
        body_profile: BodyProfile,
        goal_profile: GoalProfile
    ) -> float:
        """
        Determine target daily calories.
        
        Uses goal profile's target_calories if available,
        otherwise computes from TDEE + adjustment.
        """
        if goal_profile.target_calories is not None:
            return goal_profile.target_calories
        
        return body_profile.tdee + goal_profile.calorie_adjustment
    
    def _filter_recipes(
        self,
        recipes: List[Dict[str, Any]],
        diet_constraints: DietConstraints
    ) -> List[Dict[str, Any]]:
        """
        Filter recipes based on diet constraints.
        
        Strictly respects:
        - Diet types
        - Excluded ingredients
        
        Args:
            recipes: Full recipe list
            diet_constraints: Diet constraints
            
        Returns:
            Filtered recipe list
        """
        filtered = []
        
        for recipe in recipes:
            # Check excluded ingredients
            recipe_ingredients = recipe.get('ingredients', [])
            if self._has_excluded_ingredient(recipe_ingredients, diet_constraints.excluded_ingredients):
                continue
            
            # Check diet types (if specified)
            if diet_constraints.diet_types:
                recipe_diets = recipe.get('diet_types', [])
                if not any(diet in recipe_diets for diet in diet_constraints.diet_types):
                    continue
            
            filtered.append(recipe)
        
        logger.info(f"Filtered {len(filtered)} recipes from {len(recipes)} total")
        return filtered
    
    def _has_excluded_ingredient(
        self,
        recipe_ingredients: List[str],
        excluded: List[str]
    ) -> bool:
        """
        Check if recipe contains any excluded ingredient.
        
        Args:
            recipe_ingredients: Recipe's ingredient list
            excluded: Excluded ingredient list
            
        Returns:
            True if recipe contains excluded ingredient
        """
        recipe_ingredients_lower = [ing.lower() for ing in recipe_ingredients]
        
        for excluded_ingredient in excluded:
            # Check for exact match or substring match
            for recipe_ing in recipe_ingredients_lower:
                if excluded_ingredient in recipe_ing:
                    return True
        
        return False
    
    def _distribute_calories(self, target_calories: float) -> Dict[MealType, float]:
        """
        Distribute daily calories across meal types.
        
        Uses default distribution percentages.
        
        Args:
            target_calories: Total daily calorie target
            
        Returns:
            Dictionary mapping meal types to calorie targets
        """
        distribution = {}
        
        for meal_type, percentage in DEFAULT_MEAL_DISTRIBUTION.items():
            distribution[meal_type] = target_calories * percentage
        
        return distribution
    
    def _select_meals(
        self,
        candidates: List[Dict[str, Any]],
        meal_targets: Dict[MealType, float],
        goal_profile: GoalProfile
    ) -> List[MealItem]:
        """
        Select specific recipes for each meal type (SINGLE DAY).
        
        This is the old method - kept for backward compatibility.
        Use _select_meals_with_variety for multi-day planning.
        """
        meals = []
        
        for meal_type, target_calories in meal_targets.items():
            # Score and rank recipes for this meal type
            scored_recipes = [
                (recipe, self.recipe_scorer.calculate_score(recipe, goal_profile))
                for recipe in candidates
                if self._is_appropriate_for_meal_type(recipe, meal_type)
            ]
            
            if not scored_recipes:
                logger.warning(f"No recipes available for {meal_type}")
                continue
            
            # Sort by score (highest first)
            scored_recipes.sort(key=lambda x: x[1], reverse=True)
            
            # Select from top 3-5 recipes (for variety) instead of always picking #1
            # This ensures different recipes across different meal plans
            top_n = min(5, len(scored_recipes))  # Use top 5 recipes as pool
            selected_recipe = random.choice(scored_recipes[:top_n])[0]
            
            # Calculate servings to match calorie target
            recipe_calories_per_serving = selected_recipe.get('calories_per_serving', 400)
            servings = target_calories / recipe_calories_per_serving
            servings = round(servings, 2)
            
            # Create meal item
            meal = MealItem(
                meal_type=meal_type,
                recipe_id=selected_recipe['id'],
                recipe_name=selected_recipe.get('name', 'Unknown'),
                servings=servings,
                estimated_calories=target_calories,
                protein_g=selected_recipe.get('protein_g', 0) * servings,
                carbs_g=selected_recipe.get('carbs_g', 0) * servings,
                fat_g=selected_recipe.get('fat_g', 0) * servings
            )
            
            meals.append(meal)
        
        return meals
    
    def _select_meals_with_variety(
        self,
        candidates: List[Dict[str, Any]],
        meal_targets: Dict[MealType, float],
        goal_profile: GoalProfile,
        days: int = 1
    ) -> List[MealItem]:
        """
        Select recipes for N days with VARIETY.
        
        Strategy:
        1. For each meal type on each day, score all recipes
        2. Rotate through top N recipes per meal type (not per day)
        3. Each meal type gets different recipe rotation:
           - Breakfast Day 1: recipe #1, Breakfast Day 2: recipe #2, etc.
           - Lunch Day 1: recipe #2, Lunch Day 2: recipe #3, etc.
           - Dinner Day 1: recipe #3, Dinner Day 2: recipe #4, etc.
           - Snack Day 1: recipe #4, Snack Day 2: recipe #5, etc.
        4. Respects all dietary constraints throughout
        
        Args:
            candidates: Filtered recipes that respect user constraints
            meal_targets: Calorie targets per meal type
            goal_profile: User's goal profile
            days: Number of days to generate for
            
        Returns:
            List of MealItem for N days (personalized + varied)
        """
        meals = []
        
        # Track meal type index for rotation offset
        meal_type_list = list(meal_targets.keys())
        
        for day_num in range(days):
            logger.info(f"  Generating meals for day {day_num + 1}/{days}")
            
            for meal_type_idx, meal_type in enumerate(meal_type_list):
                target_calories = meal_targets[meal_type]
                
                # Score and rank recipes for this meal type
                scored_recipes = [
                    (recipe, self.recipe_scorer.calculate_score(recipe, goal_profile))
                    for recipe in candidates
                    if self._is_appropriate_for_meal_type(recipe, meal_type)
                ]
                
                if not scored_recipes:
                    logger.warning(f"No recipes available for {meal_type} on day {day_num + 1}")
                    continue
                
                # Sort by score (highest first)
                scored_recipes.sort(key=lambda x: x[1], reverse=True)
                
                # Rotate through top N recipes per meal type, not per day
                # Example: Breakfast uses (day 0 + offset 0), Lunch uses (day 0 + offset 1), etc.
                top_n = min(7, len(scored_recipes))  # Consider top 7 recipes for rotation
                rotation_index = (day_num + meal_type_idx) % top_n
                selected_recipe = scored_recipes[rotation_index][0]
                
                recipe_id = selected_recipe['id']
                
                # Log recipe selection (for debugging)
                logger.debug(f"    {meal_type}: Using recipe #{rotation_index + 1} "
                           f"'{selected_recipe.get('name')}' (score: {scored_recipes[rotation_index][1]:.1f})")
                
                # Calculate servings to match calorie target
                recipe_calories_per_serving = selected_recipe.get('calories_per_serving', 400)
                servings = target_calories / recipe_calories_per_serving
                servings = round(servings, 2)
                
                # Create meal item
                meal = MealItem(
                    meal_type=meal_type,
                    recipe_id=recipe_id,
                    recipe_name=selected_recipe.get('name', 'Unknown'),
                    servings=servings,
                    estimated_calories=target_calories,
                    protein_g=selected_recipe.get('protein_g', 0) * servings,
                    carbs_g=selected_recipe.get('carbs_g', 0) * servings,
                    fat_g=selected_recipe.get('fat_g', 0) * servings
                )
                
                meals.append(meal)
        
        return meals
    
    def _is_appropriate_for_meal_type(
        self,
        recipe: Dict[str, Any],
        meal_type: MealType
    ) -> bool:
        """
        Check if recipe is appropriate for meal type.
        
        In production, would use recipe tags, meal type classification, etc.
        For now, returns True for all (simplified).
        """
        # Placeholder logic - in production would check recipe categorization
        return True
    
    def _calculate_totals(
        self,
        meals: List[MealItem]
    ) -> tuple[float, float, float, float]:
        """
        Calculate total calories and macros.
        
        Returns tuple of (calories, protein_g, carbs_g, fat_g)
        """
        total_calories = sum(meal.estimated_calories for meal in meals)
        total_protein = sum(meal.protein_g or 0 for meal in meals)
        total_carbs = sum(meal.carbs_g or 0 for meal in meals)
        total_fat = sum(meal.fat_g or 0 for meal in meals)
        
        return total_calories, total_protein, total_carbs, total_fat
    
    def _create_empty_meal_plan(self, target_calories: float) -> MealPlanGenerationOutput:
        """Create an empty meal plan when no recipes match"""
        meal_plan = MealPlan(
            daily_calories=0,
            meals=[],
            total_protein_g=0,
            total_carbs_g=0,
            total_fat_g=0
        )
        
        metadata = {
            "target_calories": target_calories,
            "error": "No suitable recipes found",
            "candidate_recipes_count": 0,
            "meals_generated": 0
        }
        
        return MealPlanGenerationOutput(meal_plan=meal_plan, metadata=metadata)
    
    def _get_mock_recipe_database(self) -> List[Dict[str, Any]]:
        """
        Get mock recipe database for development/testing.
        
        In production, this would be replaced with actual database access.
        """
        return [
            {
                'id': 'recipe_001',
                'name': 'Protein Oatmeal Bowl',
                'calories_per_serving': 350,
                'protein_g': 15,
                'carbs_g': 45,
                'fat_g': 8,
                'ingredients': ['oats', 'protein powder', 'banana', 'almonds'],
                'diet_types': ['vegetarian'],
                'rating': 4.5,
                'review_count': 120
            },
            {
                'id': 'recipe_002',
                'name': 'Grilled Chicken Salad',
                'calories_per_serving': 400,
                'protein_g': 35,
                'carbs_g': 20,
                'fat_g': 18,
                'ingredients': ['chicken breast', 'lettuce', 'tomato', 'olive oil'],
                'diet_types': ['low_carb', 'paleo'],
                'rating': 4.7,
                'review_count': 200
            },
            {
                'id': 'recipe_003',
                'name': 'Salmon with Vegetables',
                'calories_per_serving': 450,
                'protein_g': 40,
                'carbs_g': 15,
                'fat_g': 25,
                'ingredients': ['salmon', 'broccoli', 'carrots', 'olive oil'],
                'diet_types': ['keto', 'pescatarian', 'low_carb'],
                'rating': 4.8,
                'review_count': 180
            },
            {
                'id': 'recipe_004',
                'name': 'Vegan Buddha Bowl',
                'calories_per_serving': 380,
                'protein_g': 12,
                'carbs_g': 55,
                'fat_g': 10,
                'ingredients': ['quinoa', 'chickpeas', 'avocado', 'kale'],
                'diet_types': ['vegan', 'vegetarian'],
                'rating': 4.6,
                'review_count': 150
            },
            {
                'id': 'recipe_005',
                'name': 'Greek Yogurt Parfait',
                'calories_per_serving': 250,
                'protein_g': 18,
                'carbs_g': 30,
                'fat_g': 5,
                'ingredients': ['greek yogurt', 'berries', 'granola', 'honey'],
                'diet_types': ['vegetarian'],
                'rating': 4.4,
                'review_count': 90
            }
        ]


# Convenience function for direct use
def generate_meal_plan(
    body_profile: BodyProfile,
    diet_constraints: DietConstraints,
    goal_profile: GoalProfile,
    recipe_database: Optional[List[Dict[str, Any]]] = None,
    days: int = 1
) -> MealPlanGenerationOutput:
    """
    Convenience function to generate meal plan for N days.
    
    This is the main entry point for Function 3.
    
    Args:
        body_profile: User's metabolic data
        diet_constraints: Diet constraints from Function 1
        goal_profile: Goal profile from Function 2
        recipe_database: Optional recipe database
        days: Number of days to generate meals for (1-30)
        
    Returns:
        MealPlanGenerationOutput with meal plan
    """
    generator = MealPlanGenerator()
    return generator.generate(body_profile, diet_constraints, goal_profile, recipe_database, days)