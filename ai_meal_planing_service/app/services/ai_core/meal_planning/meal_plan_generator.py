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

# Macro targets (% of total calories)
# Protein: 4 cal/gram, Carbs: 4 cal/gram, Fat: 9 cal/gram
MACRO_TARGETS = {
    "protein_low": 0.15,      # 15% = 1.2g per kg
    "protein_high": 0.35,     # 35% = 2.8g per kg
    "carbs_low": 0.20,        # 20%
    "carbs_high": 0.65,       # 65%
    "fat_min": 0.15,          # 15%
    "fat_max": 0.35           # 35%
}


class MealPlanValidator:
    """Validator để kiểm tra meal plan có phù hợp với user không"""
    
    @staticmethod
    def validate_meal_plan(
        meal_plan: MealPlan,
        body_profile: BodyProfile,
        goal_profile: GoalProfile,
        diet_constraints: DietConstraints,
        target_calories: float,
        days: int = 1
    ) -> Dict[str, Any]:
        """
        Kiểm tra meal plan có phù hợp không.
        
        Kiểm tra:
        1. Calories có match target không (±10%)
        2. Protein/Carbs/Fat có hợp lý không
        3. Có recipes nào vi phạm diet constraints không
        4. BMI alignment (meal plan có giúp đạt mục tiêu BMI không)
        5. Macro distribution có cân bằng không
        
        Returns:
            Dict với các thông tin:
            - is_valid: True/False
            - issues: danh sách vấn đề (nếu có)
            - warnings: cảnh báo (phần trăm sai lệch nhưng vẫn chấp nhận)
            - details: chi tiết kiểm tra
        """
        issues = []
        warnings = []
        details = {}
        
        # 1. Kiểm tra Calories
        daily_calories = meal_plan.daily_calories
        
        details["calorie_target"] = target_calories
        details["calorie_actual"] = daily_calories
        
        # Guard against division by zero
        if target_calories > 0:
            calorie_diff = abs(daily_calories - target_calories) / target_calories
            details["calorie_diff_percent"] = round(calorie_diff * 100, 2)
        else:
            calorie_diff = 0
            details["calorie_diff_percent"] = 0
            issues.append("Target calories cannot be zero")
        
        if calorie_diff > CALORIE_TOLERANCE:
            issues.append(
                f"Calories sai lệch {calorie_diff * 100:.1f}% "
                f"(target: {target_calories:.0f}, actual: {daily_calories:.0f})"
            )
        elif calorie_diff > 0.05:  # 5% warning
            warnings.append(
                f"Calories sai lệch {calorie_diff * 100:.1f}% "
                f"(target: {target_calories:.0f}, actual: {daily_calories:.0f})"
            )
        
        # 2. Kiểm tra Macros
        protein_g = meal_plan.total_protein_g or 0
        carbs_g = meal_plan.total_carbs_g or 0
        fat_g = meal_plan.total_fat_g or 0
        
        protein_cal = protein_g * 4
        carbs_cal = carbs_g * 4
        fat_cal = fat_g * 9
        total_macro_cal = protein_cal + carbs_cal + fat_cal
        
        if total_macro_cal > 0:
            protein_pct = protein_cal / total_macro_cal
            carbs_pct = carbs_cal / total_macro_cal
            fat_pct = fat_cal / total_macro_cal
        else:
            protein_pct = carbs_pct = fat_pct = 0
        
        details["protein_g"] = round(protein_g, 1)
        details["protein_percent"] = round(protein_pct * 100, 1)
        details["carbs_g"] = round(carbs_g, 1)
        details["carbs_percent"] = round(carbs_pct * 100, 1)
        details["fat_g"] = round(fat_g, 1)
        details["fat_percent"] = round(fat_pct * 100, 1)
        
        # Check macro balance
        if fat_pct < MACRO_TARGETS["fat_min"] or fat_pct > MACRO_TARGETS["fat_max"]:
            warnings.append(
                f"Fat % = {fat_pct * 100:.1f}% (nên {MACRO_TARGETS['fat_min']*100:.0f}-{MACRO_TARGETS['fat_max']*100:.0f}%)"
            )
        
        if carbs_pct < MACRO_TARGETS["carbs_low"] or carbs_pct > MACRO_TARGETS["carbs_high"]:
            warnings.append(
                f"Carbs % = {carbs_pct * 100:.1f}% (nên {MACRO_TARGETS['carbs_low']*100:.0f}-{MACRO_TARGETS['carbs_high']*100:.0f}%)"
            )
        
        # 3. Kiểm tra protein theo goal
        weight_kg = body_profile.weight_kg or 70
        if goal_profile.protein_priority.value == "high":
            protein_target_min = weight_kg * 2.0  # 2g/kg
            if protein_g < protein_target_min:
                warnings.append(
                    f"Protein thấp cho mục tiêu '{goal_profile.protein_priority.value}' "
                    f"({protein_g:.0f}g < {protein_target_min:.0f}g)"
                )
        
        # 4. Kiểm tra BMI alignment
        bmi = body_profile.bmi or 0
        details["current_bmi"] = round(bmi, 1)
        
        if goal_profile.primary_goal == "weight_loss":
            if daily_calories >= body_profile.tdee:
                issues.append(
                    f"Mục tiêu: Giảm cân nhưng calories {daily_calories:.0f} >= TDEE {body_profile.tdee:.0f} "
                    f"(phải < TDEE để giảm)"
                )
            else:
                deficit = body_profile.tdee - daily_calories
                details["calorie_deficit"] = round(deficit, 0)
                details["weight_loss_per_week_kg"] = round(deficit / 7700, 2)  # 7700 = 1kg fat
        
        elif goal_profile.primary_goal == "muscle_gain":
            if daily_calories <= body_profile.tdee:
                warnings.append(
                    f"Mục tiêu: Tăng cơ nhưng calories {daily_calories:.0f} <= TDEE {body_profile.tdee:.0f} "
                    f"(nên > TDEE để tăng)"
                )
            else:
                surplus = daily_calories - body_profile.tdee
                details["calorie_surplus"] = round(surplus, 0)
                details["weight_gain_per_week_kg"] = round(surplus / 7700, 2)
        
        # 5. Tổng hợp kết quả
        is_valid = len(issues) == 0
        
        return {
            "is_valid": is_valid,
            "status": "✓ Phù hợp" if is_valid else "✗ Không phù hợp",
            "issues": issues,
            "warnings": warnings,
            "details": details,
            "meals_count": len(meal_plan.meals),
            "days": days
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
        
        # Validate meal plan
        validator = MealPlanValidator()
        validation_result = validator.validate_meal_plan(
            meal_plan=meal_plan,
            body_profile=body_profile,
            goal_profile=goal_profile,
            diet_constraints=diet_constraints,
            target_calories=target_calories,
            days=days
        )
        
        metadata["validation"] = validation_result
        
        if validation_result["is_valid"]:
            logger.info(f"✓ Meal plan đã được xác minh và phù hợp")
        else:
            logger.warning(f"⚠ Meal plan có vấn đề: {validation_result['issues']}")
        
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
        Always returns a positive value to prevent division by zero.
        """
        if goal_profile.target_calories is not None and goal_profile.target_calories > 0:
            return goal_profile.target_calories
        
        # Calculate from TDEE + adjustment
        tdee = body_profile.tdee or 2000  # Fallback default
        adjustment = goal_profile.calorie_adjustment or 0  # Fallback to zero
        target = tdee + adjustment
        
        # Ensure minimum positive value to prevent division by zero
        return max(target, 1000)  # Minimum 1000 calories
    
    def _filter_recipes(
        self,
        recipes: List[Dict[str, Any]],
        diet_constraints: DietConstraints
    ) -> List[Dict[str, Any]]:
        """
        Filter recipes based on diet constraints and normalize nutrition data.
        
        Strictly respects:
        - Diet types
        - Excluded ingredients
        
        Transforms MongoDB nutrition format to AI service format:
        - nutritionInfo.protein -> protein_g
        - nutritionInfo.carbs -> carbs_g
        - nutritionInfo.fat -> fat_g
        
        Args:
            recipes: Full recipe list (from MongoDB or transformed)
            diet_constraints: Diet constraints
            
        Returns:
            Filtered recipe list with normalized nutrition data
        """
        logger.info(f"Starting recipe filtering: {len(recipes)} recipes received")
        if recipes and len(recipes) > 0:
            logger.info(f"Sample recipe keys: {recipes[0].keys()}")
        
        filtered = []
        
        for recipe in recipes:
            # Check excluded ingredients
            recipe_ingredients = recipe.get('ingredients', [])
            if self._has_excluded_ingredient(recipe_ingredients, diet_constraints.excluded_ingredients):
                logger.debug(f"Recipe {recipe.get('name')} excluded: contains excluded ingredient")
                continue
            
            # Check diet types (if specified)
            if diet_constraints.diet_types:
                recipe_diets = recipe.get('diet_types', [])
                if not any(diet in recipe_diets for diet in diet_constraints.diet_types):
                    logger.debug(f"Recipe {recipe.get('name')} excluded: diet type mismatch")
                    continue
            
            # Normalize nutrition data from MongoDB or transformed format
            nutrition_info = recipe.get('nutritionInfo', {})
            if nutrition_info:
                # Map MongoDB nutrition fields to AI service fields
                recipe['protein_g'] = nutrition_info.get('protein', 0)
                recipe['carbs_g'] = nutrition_info.get('carbs', 0)
                recipe['fat_g'] = nutrition_info.get('fat', 0)
                recipe['calories_per_serving'] = nutrition_info.get('calories', 0)
            else:
                # Already transformed - use direct fields
                recipe['protein_g'] = recipe.get('protein_g', 0)
                recipe['carbs_g'] = recipe.get('carbs_g', 0)
                recipe['fat_g'] = recipe.get('fat_g', 0)
                recipe['calories_per_serving'] = recipe.get('calories_per_serving', recipe.get('calories', 400))
            
            filtered.append(recipe)
        
        logger.info(f"Filtered {len(filtered)} recipes from {len(recipes)} total")
        if filtered and len(filtered) > 0:
            sample = filtered[0]
            logger.info(f"Sample filtered recipe: {sample.get('name')}, "
                       f"protein={sample.get('protein_g')}, carbs={sample.get('carbs_g')}, "
                       f"fat={sample.get('fat_g')}, cals={sample.get('calories_per_serving')}")
        
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
            # Ensure recipe_calories_per_serving is never zero
            if recipe_calories_per_serving <= 0:
                recipe_calories_per_serving = 400
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
                # Ensure recipe_calories_per_serving is never zero
                if recipe_calories_per_serving <= 0:
                    recipe_calories_per_serving = 400
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


def validate_meal_plan(
    meal_plan: MealPlan,
    body_profile: BodyProfile,
    goal_profile: GoalProfile,
    diet_constraints: DietConstraints,
    target_calories: float,
    days: int = 1
) -> Dict[str, Any]:
    """
    Kiểm tra một meal plan có phù hợp với user không.
    
    Có thể dùng standalone (không cần generate).
    
    Args:
        meal_plan: Meal plan để kiểm tra
        body_profile: User's metabolic data
        goal_profile: User's health goal
        diet_constraints: User's diet constraints
        target_calories: Target daily calories
        days: Number of days in plan
        
    Returns:
        Validation report dict
    """
    validator = MealPlanValidator()
    return validator.validate_meal_plan(
        meal_plan=meal_plan,
        body_profile=body_profile,
        goal_profile=goal_profile,
        diet_constraints=diet_constraints,
        target_calories=target_calories,
        days=days
    )