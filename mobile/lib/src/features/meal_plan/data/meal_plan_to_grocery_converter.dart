import 'package:flutter/foundation.dart';
import '../domain/meal_plan_models.dart';
import '../../home/domain/recipe_models.dart';
import '../../grocery/domain/grocery_models.dart';

/// Service to convert meal plans to grocery list items
class MealPlanToGroceryConverter {
  /// Extracts and consolidates grocery items from a meal plan
  /// Groups ingredients by ingredientId and sums quantities
  static List<GroceryItem> convertMealPlanToGroceryItems(
    MealPlanGenerationResult mealPlan,
    Map<String, List<dynamic>> recipeIngredientsMap,
  ) {
    final Map<String, GroceryItem> consolidatedItems = {};

    // Process each meal in the meal plan
    for (final item in mealPlan.items) {
      if (item.recipeId == null || item.recipeId!.isEmpty) continue;

      // Get ingredients for this recipe
      final dynamicIngredients = recipeIngredientsMap[item.recipeId];
      if (dynamicIngredients == null || dynamicIngredients.isEmpty) continue;

      // Cast to RecipeIngredient
      final ingredients = dynamicIngredients.cast<RecipeIngredient>();

      // Add/consolidate each ingredient
      for (final recipeIngredient in ingredients) {
        final ingredient = recipeIngredient.ingredient;

        // Calculate quantity based on servings (scale from base recipe)
        final scaledQuantity = _parseQuantity(recipeIngredient.baseQuantity) *
            (item.servings > 0 ? item.servings : 1);

        final key = ingredient.id;

        if (consolidatedItems.containsKey(key)) {
          // Ingredient already exists - add to quantity
          final existing = consolidatedItems[key]!;
          consolidatedItems[key] = existing.copyWith(
            quantity: existing.quantity + scaledQuantity,
          );
        } else {
          // New ingredient
          consolidatedItems[key] = GroceryItem(
            id: '', // Will be assigned by backend
            ingredientId: ingredient.id,
            name: ingredient.name,
            quantity: scaledQuantity,
            unit: recipeIngredient.unit,
            recipeId: item.recipeId,
            recipeName: item.recipeName,
          );
        }
      }
    }

    return consolidatedItems.values.toList();
  }

  /// Parse quantity string to double
  /// Handles formats like "1", "1.5", "2 1/2", etc.
  static double _parseQuantity(String quantityStr) {
    try {
      // Remove extra whitespace
      final cleaned = quantityStr.trim();

      // Try simple double parsing first
      if (!cleaned.contains('/') && !cleaned.contains(' ')) {
        return double.parse(cleaned);
      }

      // Handle fractions like "2 1/2" or "1/4"
      if (cleaned.contains(' ')) {
        final parts = cleaned.split(' ');
        double result = 0;

        for (final part in parts) {
          if (part.contains('/')) {
            final fractionParts = part.split('/');
            if (fractionParts.length == 2) {
              final numerator = double.tryParse(fractionParts[0]) ?? 0;
              final denominator = double.tryParse(fractionParts[1]) ?? 1;
              result += numerator / denominator;
            }
          } else {
            result += double.tryParse(part) ?? 0;
          }
        }
        return result;
      }

      // Handle simple fractions like "1/4"
      if (cleaned.contains('/')) {
        final parts = cleaned.split('/');
        if (parts.length == 2) {
          final numerator = double.tryParse(parts[0]) ?? 0;
          final denominator = double.tryParse(parts[1]) ?? 1;
          return numerator / denominator;
        }
      }

      return double.parse(cleaned);
    } catch (e) {
      debugPrint('⚠️ Failed to parse quantity "$quantityStr": $e');
      return 0;
    }
  }
}
