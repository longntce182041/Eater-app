"""
Function 1: Analyze Dietary Preferences

This module acts as a constraint builder for meal planning.
It determines what the user can and cannot eat based on dietary restrictions.

Rules:
- Stateless and deterministic
- Does NOT generate meal plans
- Does NOT access database directly
- Only builds normalized diet constraints
"""
from typing import List, Set
from app.api.schemas.meal_plan_pipeline import (
    DietaryPreferencesInput,
    DietaryPreferencesOutput,
    DietConstraints
)
import logging

logger = logging.getLogger(__name__)

# Supported diet types (can be extended)
SUPPORTED_DIET_TYPES = {
    "keto",
    "vegan",
    "vegetarian",
    "paleo",
    "mediterranean",
    "low_carb",
    "low_fat",
    "gluten_free",
    "dairy_free",
    "halal",
    "kosher",
    "pescatarian"
}


class DietaryPreferencesAnalyzer:
    """
    Analyzes dietary preferences and produces normalized diet constraints.
    
    This is a pure function class - stateless and deterministic.
    """
    
    def __init__(self):
        """Initialize the analyzer with supported diet types"""
        self.supported_diets = SUPPORTED_DIET_TYPES
    
    def analyze(
        self,
        diet_types: List[str],
        allergies: List[str],
        disliked_ingredients: List[str]
    ) -> DietaryPreferencesOutput:
        """
        Analyze dietary preferences and produce normalized constraints.
        
        Processing Flow:
        1. Normalize all inputs to lowercase
        2. Validate diet types against supported list
        3. Merge allergies + disliked_ingredients
        4. Remove duplicates
        5. Return structured constraints
        
        Args:
            diet_types: List of diet type strings (e.g., ["keto", "vegan"])
            allergies: List of allergen ingredients
            disliked_ingredients: List of disliked ingredients
            
        Returns:
            DietaryPreferencesOutput with normalized diet_constraints
            
        Example:
            >>> analyzer = DietaryPreferencesAnalyzer()
            >>> result = analyzer.analyze(
            ...     diet_types=["Keto", "GLUTEN_FREE"],
            ...     allergies=["Peanuts", "Shellfish"],
            ...     disliked_ingredients=["mushrooms", "PEANUTS"]
            ... )
            >>> result.diet_constraints.diet_types
            ['keto', 'gluten_free']
            >>> result.diet_constraints.excluded_ingredients
            ['mushrooms', 'peanuts', 'shellfish']
        """
        logger.info(f"Analyzing dietary preferences: {len(diet_types)} diet types, "
                   f"{len(allergies)} allergies, {len(disliked_ingredients)} dislikes")
        
        # Step 1: Normalize and validate diet types
        validated_diet_types = self._validate_diet_types(diet_types)
        
        # Step 2: Normalize and merge excluded ingredients
        excluded_ingredients = self._merge_exclusions(allergies, disliked_ingredients)
        
        # Step 3: Build constraints object
        diet_constraints = DietConstraints(
            diet_types=validated_diet_types,
            excluded_ingredients=excluded_ingredients
        )
        
        logger.info(f"Diet constraints built: {len(validated_diet_types)} diets, "
                   f"{len(excluded_ingredients)} exclusions")
        
        return DietaryPreferencesOutput(diet_constraints=diet_constraints)
    
    def _validate_diet_types(self, diet_types: List[str]) -> List[str]:
        """
        Validate and normalize diet types.
        
        Args:
            diet_types: Raw diet type list
            
        Returns:
            List of validated, normalized diet types
        """
        if not diet_types:
            return []
        
        validated = []
        for diet in diet_types:
            # Normalize to lowercase and replace spaces with underscores
            normalized = diet.lower().strip().replace(" ", "_")
            
            # Check if supported
            if normalized in self.supported_diets:
                validated.append(normalized)
            else:
                logger.warning(f"Unsupported diet type '{diet}' ignored. "
                             f"Supported: {self.supported_diets}")
        
        # Remove duplicates while preserving order
        return list(dict.fromkeys(validated))
    
    def _merge_exclusions(
        self,
        allergies: List[str],
        disliked_ingredients: List[str]
    ) -> List[str]:
        """
        Merge and normalize allergies and dislikes.
        
        Args:
            allergies: List of allergen ingredients
            disliked_ingredients: List of disliked ingredients
            
        Returns:
            Sorted list of unique, normalized ingredient names
        """
        # Use set for efficient deduplication
        exclusions: Set[str] = set()
        
        # Normalize allergies
        for allergen in allergies:
            normalized = allergen.lower().strip()
            if normalized:
                exclusions.add(normalized)
        
        # Normalize dislikes
        for ingredient in disliked_ingredients:
            normalized = ingredient.lower().strip()
            if normalized:
                exclusions.add(normalized)
        
        # Return sorted list for deterministic output
        return sorted(list(exclusions))
    
    def get_supported_diet_types(self) -> List[str]:
        """
        Get list of all supported diet types.
        
        Returns:
            Sorted list of supported diet type names
        """
        return sorted(list(self.supported_diets))


# Convenience function for direct use
def analyze_dietary_preferences(
    diet_types: List[str],
    allergies: List[str],
    disliked_ingredients: List[str]
) -> DietaryPreferencesOutput:
    """
    Convenience function to analyze dietary preferences.
    
    This is the main entry point for Function 1.
    
    Args:
        diet_types: List of diet types
        allergies: List of allergens
        disliked_ingredients: List of disliked ingredients
        
    Returns:
        DietaryPreferencesOutput with normalized constraints
    """
    analyzer = DietaryPreferencesAnalyzer()
    return analyzer.analyze(diet_types, allergies, disliked_ingredients)
