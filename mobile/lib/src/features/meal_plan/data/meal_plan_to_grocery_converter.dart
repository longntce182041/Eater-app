import 'package:flutter/foundation.dart';
import '../domain/meal_plan_models.dart';
import '../../home/domain/recipe_models.dart';
import '../../grocery/domain/grocery_models.dart';

/// 🔄 MEAL PLAN TO GROCERY LIST CONVERTER SERVICE
///
/// Converts meal plan data into grocery list items
/// Handles ingredient consolidation and quantity scaling
/// This service bridges the meal planning and grocery list features
///
/// Key Responsibilities:
/// 1. Extract ingredients from multiple recipes in meal plan
/// 2. Consolidate duplicate ingredients by ID
/// 3. Sum quantities for the same ingredient (e.g., 2 recipes with tomatoes)
/// 4. Scale quantities based on meal servings
/// 5. Create GroceryItem objects for grocery list
///
/// Architecture:
/// ```
/// Meal Plan (7 days, 21 meals)
///   ├─ Day 0: Breakfast (2 servings) → Recipe A → 3 ingredients
///   ├─ Day 0: Lunch (1 serving) → Recipe B → 4 ingredients
///   └─ ...
///        ↓
///   CONSOLIDATION STEP
///   [Tomato appears 4 times across different meals]
///   [Tomato ID: ingredient_123]
///        ↓
///   SCALING STEP
///   [Recipe servings: 2 serving required]
///   [Base quantity: 1 cup]
///   [Scaled: 1 × 2 = 2 cups]
///        ↓
///   OUTPUT: GroceryItem List
///   [Tomato: 4 cups total]
///   [Onion: 3 cups total]
///   [...more consolidated items]
/// ```
///
/// Usage:
/// ```dart
/// // Get meal plan with recipes
/// final mealPlan = MealPlanGenerationResult(...);
///
/// // Fetch ingredients for each recipe
/// final ingredientsMap = <String, List<dynamic>>{};
/// for (final item in mealPlan.items) {
///   final ingredients = await api.getRecipeIngredients(item.recipeId!);
///   ingredientsMap[item.recipeId!] = ingredients;
/// }
///
/// // Convert to grocery items (consolidates duplicates)
/// final groceryItems = MealPlanToGroceryConverter
///   .convertMealPlanToGroceryItems(mealPlan, ingredientsMap);
///
/// // Add to grocery list
/// await groceryNotifier.addItems(groceryItems);
/// ```
class MealPlanToGroceryConverter {
  /// 🔄 Extract and consolidate grocery items from meal plan
  ///
  /// Algorithm:
  /// 1. Iterate through all meal items in the meal plan
  /// 2. For each meal, fetch its recipe ingredients
  /// 3. Scale each ingredient by meal servings
  /// 4. Group ingredients by ingredientId (consolidation key)
  /// 5. Sum quantities for same ingredient across meals
  /// 6. Return consolidated list as GroceryItems
  ///
  /// Features:
  /// - ✅ Automatic deduplication by ingredientId
  /// - ✅ Quantity aggregation (consolidates duplicates)
  /// - ✅ Serving-based scaling (accounts for recipe portions)
  /// - ✅ Error resilience (continues if some ingredient fetch fails)
  /// - ✅ Handles parsing of various quantity formats
  ///
  /// Parameters:
  /// - mealPlan: Complete meal plan with all meals and days
  /// - recipeIngredientsMap: Map of recipeId → list of RecipeIngredient objects
  ///   (built by caller before calling this method)
  ///
  /// Returns:
  /// - `List<GroceryItem>`: Consolidated grocery items, one per unique ingredient
  ///
  /// Example Flow:
  /// ```
  /// Meal Plan Items:
  /// 1. Breakfast Day 1: Pasta Recipe, 2 servings
  ///    - Tomato: 1 cup (base) × 2 servings = 2 cups
  ///    - Olive Oil: 0.5 cup × 2 servings = 1 cup
  ///
  /// 2. Lunch Day 1: Salad Recipe, 1 serving
  ///    - Tomato: 2 cups (base) × 1 serving = 2 cups
  ///    - Lettuce: 1 head × 1 = 1 head
  ///
  /// CONSOLIDATION:
  /// - Tomato (ID: ing_123):
  ///   2 cups + 2 cups = 4 cups TOTAL
  /// - Olive Oil (ID: ing_456):
  ///   1 cup = 1 cup TOTAL
  /// - Lettuce (ID: ing_789):
  ///   1 head = 1 head TOTAL
  /// ```
  static List<GroceryItem> convertMealPlanToGroceryItems(
    MealPlanGenerationResult mealPlan,
    Map<String, List<dynamic>> recipeIngredientsMap,
  ) {
    /// 📦 Map to consolidate items by ingredient ID
    /// Key: ingredient._id (unique ingredient identifier)
    /// Value: GroceryItem (will be updated with summed quantities)
    final Map<String, GroceryItem> consolidatedItems = {};

    /// 🔁 Process each meal in the meal plan
    /// Iterate through all meals across all days
    for (final item in mealPlan.items) {
      /// ⏭️ Skip meals without recipe references
      /// Some meals might be placeholders or undefined
      if (item.recipeId == null || item.recipeId!.isEmpty) continue;

      /// 🔍 Get ingredients for this recipe
      /// Retrieve from the pre-fetched map
      final dynamicIngredients = recipeIngredientsMap[item.recipeId];
      if (dynamicIngredients == null || dynamicIngredients.isEmpty) continue;

      /// 📝 Cast dynamic list to RecipeIngredient type
      /// This is where runtime type casting happens
      final ingredients = dynamicIngredients.cast<RecipeIngredient>();

      /// 🔄 Add/consolidate each ingredient
      /// Iterate through all ingredients in this recipe
      for (final recipeIngredient in ingredients) {
        final ingredient = recipeIngredient.ingredient;

        /// ⚖️ Calculate SCALED quantity
        /// Formula: baseQuantity × servings
        /// Example: Pasta recipe base is 2 cups, this meal uses 3 servings
        ///          Result: 2 × 3 = 6 cups for this meal
        ///
        /// The baseQuantity is the amount in the original recipe
        /// The item.servings is how many servings we're preparing
        final scaledQuantity = _parseQuantity(recipeIngredient.baseQuantity) *
            (item.servings > 0 ? item.servings : 1);

        /// 🔑 Use ingredient ID as consolidation key
        /// Ensures same ingredient from different recipes combines
        final key = ingredient.id;

        if (consolidatedItems.containsKey(key)) {
          /// ✏️ Ingredient already exists in consolidation map
          /// Update it by adding the new quantity to existing
          ///
          /// Example:
          /// - Tomato already in map: 2 cups
          /// - New tomato from recipe: 1.5 cups
          /// - Result: 2 + 1.5 = 3.5 cups total
          final existing = consolidatedItems[key]!;
          consolidatedItems[key] = existing.copyWith(
            quantity: existing.quantity + scaledQuantity,
          );
        } else {
          /// ✨ New ingredient (first occurrence)
          /// Create new GroceryItem with scaled quantity
          consolidatedItems[key] = GroceryItem(
            id: '', // Will be assigned by backend when saved
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

    /// 📤 Return consolidated list of grocery items
    /// One item per unique ingredient with total quantity summed
    return consolidatedItems.values.toList();
  }

  /// 🔢 Parse quantity string to double value
  ///
  /// Handles multiple quantity format variations:
  /// - Simple decimals: "1.5" → 1.5
  /// - Whole numbers: "2" → 2.0
  /// - Fractions: "1/4" → 0.25
  /// - Mixed numbers: "2 1/2" → 2.5
  /// - Complex: "1 1/3 + 1/2" (depends on data format)
  ///
  /// Why this is needed:
  /// - Backend stores quantities as strings to preserve precision
  /// - Different recipes may use different formats
  /// - Recipes from different sources use varied conventions
  /// - Need to convert to double for calculation
  ///
  /// Examples:
  /// ```
  /// "1" → 1.0
  /// "1.5" → 1.5
  /// "2.5" → 2.5
  /// "1/2" → 0.5
  /// "1/4" → 0.25
  /// "3/4" → 0.75
  /// "2 1/2" → 2.5
  /// "1 1/3" → 1.333...
  /// "2 3/4" → 2.75
  /// ```
  ///
  /// Algorithm:
  /// 1. Trim whitespace from input
  /// 2. Check if contains fractions or spaces (indicates complex format)
  /// 3. If simple decimal/number: parse directly
  /// 4. If contains space: split and parse mixed number (whole + fraction)
  /// 5. If contains slash: parse as simple fraction (numerator / denominator)
  /// 6. If parsing fails: return 0 and log warning
  ///
  /// Parameters:
  /// - quantityStr: String version of quantity (from recipe data)
  ///
  /// Returns:
  /// - double: Parsed numeric quantity (0 if parsing fails)
  ///
  /// Error Handling:
  /// - Catches parsing exceptions gracefully
  /// - Logs error with debugPrint (won't crash app)
  /// - Returns 0 as fallback (ingredient will still be added, just with 0 quantity)
  static double _parseQuantity(String quantityStr) {
    try {
      /// 🧹 Remove extra whitespace from input
      final cleaned = quantityStr.trim();

      /// 🔍 Quick path: no fractions or spaces = simple decimal
      /// Examples: "1", "1.5", "2.25"
      if (!cleaned.contains('/') && !cleaned.contains(' ')) {
        return double.parse(cleaned);
      }

      /// 📐 Mixed number format: "2 1/2" style
      /// Split by space to get [whole_number, fraction_part]
      if (cleaned.contains(' ')) {
        final parts = cleaned.split(' ');
        double result = 0;

        /// 🔄 Process each part (whole number + fractions)
        for (final part in parts) {
          if (part.contains('/')) {
            /// ㄱ Process fraction part
            /// Examples: "1/2", "3/4"
            final fractionParts = part.split('/');
            if (fractionParts.length == 2) {
              final numerator = double.tryParse(fractionParts[0]) ?? 0;
              final denominator = double.tryParse(fractionParts[1]) ?? 1;
              result += numerator / denominator;
            }
          } else {
            /// 🔢 Process whole number part
            result += double.tryParse(part) ?? 0;
          }
        }
        return result;
      }

      /// 📊 Simple fraction format: "1/4" style
      /// Split by slash to get [numerator, denominator]
      if (cleaned.contains('/')) {
        final parts = cleaned.split('/');
        if (parts.length == 2) {
          final numerator = double.tryParse(parts[0]) ?? 0;
          final denominator = double.tryParse(parts[1]) ?? 1;
          return numerator / denominator;
        }
      }

      /// 🚫 Fallback: try to parse as decimal
      return double.parse(cleaned);
    } catch (e) {
      /// ⚠️ Log parsing error but don't crash
      debugPrint('⚠️ Failed to parse quantity "$quantityStr": $e');
      return 0;
    }
  }
}
