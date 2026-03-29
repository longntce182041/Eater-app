import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/app_config_provider.dart';
import '../../../shared/providers/dio_provider.dart';
import '../domain/meal_plan_models.dart';

/// 📡 MEAL PLAN API CLIENT PROVIDER
///
/// Riverpod provider that creates and manages the HTTP API client
/// Ensures single instance of MealPlanApiClient across app
/// Provides authenticated Dio instance and base URL from config
final mealPlanApiClientProvider = Provider<MealPlanApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  final config = ref.watch(appConfigProvider);
  return MealPlanApiClient(dio, config.apiBaseUrl);
});

/// 🍽️ MEAL PLAN API CLIENT
///
/// HTTP client for meal plan endpoints
/// Handles all communication with meal plan backend API
/// Provides methods for generation, fetching, modification
///
/// Features:
/// - ✅ AI meal plan generation
/// - ✅ Fetch latest/historical plans
/// - ✅ Delete individual or all plans
/// - ✅ Rate/replace meals in plans
/// - ✅ Optimize entire meal plans
/// - ✅ Preview generation before saving
/// - ✅ Save modified meals
///
/// Base URL Example:
/// - Production: https://api.eater.com
/// - Staging: https://staging-api.eater.com
/// - Local Dev: http://localhost:3000
///
/// Authentication:
/// - All requests use Dio with auth interceptor
/// - Bearer token automatically added to headers
/// - Token refresh handled by dioProvider
///
/// Error Handling:
/// - Checks response.success flag (custom API wrapper)
/// - Throws Exception with error message from backend
/// - Logs errors with debugPrint (non-production logging)
///
/// API Response Structure (Standard):
/// ```json
/// {
///   "success": true,
///   "message": "Success message (optional)",
///   "data": { ... }, // Actual data (varies by endpoint)
///   "timestamp": "2024-03-15T10:30:00Z"
/// }
/// ```
class MealPlanApiClient {
  final Dio _dio;
  final String baseUrl;

  MealPlanApiClient(this._dio, this.baseUrl);

  /// 🤖 Generate a new AI meal plan
  ///
  /// Endpoint: POST /api/ai/meal-plan/generate
  ///
  /// Generates a new meal plan using AI algorithms
  /// Can use traditional rules OR machine learning models
  ///
  /// Parameters:
  /// - days: Number of days to generate (3, 7, 14, 30, etc.)
  /// - useML: Whether to use ML model (false = rule-based)
  ///
  /// Request Body:
  /// ```json
  /// {
  ///   "days": 7,
  ///   "useML": false
  /// }
  /// ```
  ///
  /// Response Data:
  /// - Complete MealPlanGenerationResult with items and summary
  ///
  /// Success Response Example:
  /// ```json
  /// {
  ///   "success": true,
  ///   "data": {
  ///     "mealPlan": { "_id": "123", "days": 7, ... },
  ///     "items": [ ... 21 meals ... ],
  ///     "summary": { "totalMeals": 21, "avgCaloriesPerDay": 2000 }
  ///   }
  /// }
  /// ```
  ///
  /// Throws:
  /// - Exception: If success != true (check message field)
  ///
  /// Usage:
  /// ```dart
  /// final client = ref.read(mealPlanApiClientProvider);
  /// final result = await client.generateMealPlan(
  ///   days: 7,
  ///   useML: true,
  /// );
  /// print('Generated ${result.items.length} meals');
  /// ```
  Future<MealPlanGenerationResult> generateMealPlan({
    required int days,
    bool useML = false,
  }) async {
    final url = '$baseUrl/api/ai/meal-plan/generate';
    final res = await _dio.post(url, data: {'days': days, 'useML': useML});

    final data = res.data as Map<String, dynamic>;
    if (data['success'] != true) {
      debugPrint('generateMealPlan error: ${data['message']}');
      throw Exception(data['message'] ?? 'Failed to generate meal plan');
    }

    final payload = (data['data'] as Map<String, dynamic>?) ?? {};
    return MealPlanGenerationResult.fromJson(payload);
  }

  /// 📋 Fetch the latest saved meal plan for user
  ///
  /// Endpoint: GET /api/ai/meal-plans/latest
  ///
  /// Retrieves the most recently saved meal plan
  /// Does NOT fetch historical/archived plans
  /// Returns null if user has no saved meal plans
  ///
  /// Query Parameters: None (uses authenticated user from token)
  ///
  /// Response Data:
  /// - MealPlanGenerationResult or null if no plan exists
  ///
  /// Success Response Example:
  /// ```json
  /// {
  ///   "success": true,
  ///   "data": {
  ///     "mealPlan": { "_id": "latest_plan_id", ... },
  ///     "items": [ ... ],
  ///     "summary": { ... }
  ///   }
  /// }
  /// ```
  ///
  /// Empty Response (No Plan):
  /// ```json
  /// {
  ///   "success": true,
  ///   "data": null
  /// }
  /// ```
  ///
  /// Throws:
  /// - Exception: If success != true
  ///
  /// Returns:
  /// - MealPlanGenerationResult: If plan exists
  /// - null: If user has no saved plans
  ///
  /// Usage:
  /// ```dart
  /// final client = ref.read(mealPlanApiClientProvider);
  /// final latestPlan = await client.fetchLatestMealPlan();
  /// if (latestPlan != null) {
  ///   print('Found plan from ${latestPlan.mealPlan.date}');
  /// } else {
  ///   print('No saved plans');
  /// }
  /// ```
  Future<MealPlanGenerationResult?> fetchLatestMealPlan() async {
    final url = '$baseUrl/api/ai/meal-plans/latest';
    final res = await _dio.get(url);

    final data = res.data as Map<String, dynamic>;
    if (data['success'] != true) {
      debugPrint('fetchLatestMealPlan error: ${data['message']}');
      throw Exception(data['message'] ?? 'Failed to fetch meal plan');
    }

    final payload = data['data'] as Map<String, dynamic>?;
    if (payload == null) return null;
    return MealPlanGenerationResult.fromJson(payload);
  }

  /// 🗑️ Delete the latest meal plan (soft delete)
  ///
  /// Endpoint: DELETE /api/ai/meal-plans/latest
  ///
  /// Deletes/archives the most recently saved plan
  /// User can still access historical plans if they exist
  ///
  /// Query Parameters: None
  /// Request Body: None
  ///
  /// Success Response Example:
  /// ```json
  /// {
  ///   "success": true,
  ///   "message": "Meal plan deleted successfully",
  ///   "data": null
  /// }
  /// ```
  ///
  /// Throws:
  /// - Exception: If success != true
  ///
  /// Usage:
  /// ```dart
  /// final client = ref.read(mealPlanApiClientProvider);
  /// await client.deleteLatestMealPlan();
  /// print('Latest plan deleted');
  /// ```
  Future<void> deleteLatestMealPlan() async {
    final url = '$baseUrl/api/ai/meal-plans/latest';
    final res = await _dio.delete(url);

    final data = res.data as Map<String, dynamic>;
    if (data['success'] != true) {
      debugPrint('deleteLatestMealPlan error: ${data['message']}');
      throw Exception(data['message'] ?? 'Failed to delete meal plan');
    }
  }

  /// 🗑️ Delete a specific meal plan by ID
  ///
  /// Endpoint: DELETE /api/ai/meal-plans/:mealPlanId
  ///
  /// Deletes a specific meal plan (not necessarily the latest)
  /// Useful for cleaning up old plans
  ///
  /// URL Parameters:
  /// - mealPlanId: ID of the meal plan to delete
  ///
  /// Success Response Example:
  /// ```json
  /// {
  ///   "success": true,
  ///   "message": "Meal plan deleted",
  ///   "data": null
  /// }
  /// ```
  ///
  /// Throws:
  /// - Exception: If success != true or plan not found
  ///
  /// Usage:
  /// ```dart
  /// await client.deleteMealPlanById('507f1f77bcf86cd799439011');
  /// ```
  Future<void> deleteMealPlanById(String mealPlanId) async {
    final url = '$baseUrl/api/ai/meal-plans/$mealPlanId';
    final res = await _dio.delete(url);

    final data = res.data as Map<String, dynamic>;
    if (data['success'] != true) {
      debugPrint('deleteMealPlanById error: ${data['message']}');
      throw Exception(data['message'] ?? 'Failed to delete meal plan');
    }
  }

  /// 🗑️ Delete ALL meal plans for user (destructive)
  ///
  /// Endpoint: DELETE /api/ai/meal-plans
  ///
  /// Permanently deletes all meal plans
  /// ⚠️ This is a destructive operation - no undo!
  /// UI should require confirmation before calling
  ///
  /// Request Body: None
  ///
  /// Success Response Example:
  /// ```json
  /// {
  ///   "success": true,
  ///   "message": "All meal plans deleted",
  ///   "data": { "deletedCount": 5 }
  /// }
  /// ```
  ///
  /// Throws:
  /// - Exception: If success != true
  ///
  /// Usage:
  /// ```dart
  /// // Get user confirmation first!
  /// final confirmed = await showConfirmDialog();
  /// if (confirmed) {
  ///   await client.deleteAllMealPlans();
  ///   print('All plans deleted');
  /// }
  /// ```
  Future<void> deleteAllMealPlans() async {
    final url = '$baseUrl/api/ai/meal-plans';
    final res = await _dio.delete(url);

    final data = res.data as Map<String, dynamic>;
    if (data['success'] != true) {
      debugPrint('deleteAllMealPlans error: ${data['message']}');
      throw Exception(data['message'] ?? 'Failed to delete meal plans');
    }
  }

  /// 💡 Get replacement suggestions for a meal
  ///
  /// Endpoint: GET /api/meal-plans/:planId/items/:itemId/suggestions
  ///
  /// Gets list of alternative recipes for a meal
  /// User can browse and choose replacements
  /// Useful for: don't like meal, allergy/restriction, dietary preference
  ///
  /// URL Parameters:
  /// - planId: ID of the meal plan
  /// - itemId: ID of the meal item to replace
  ///
  /// Query Parameters: None
  ///
  /// Response Structure:
  /// ```json
  /// {
  ///   "success": true,
  ///   "data": {
  ///     "suggestions": [
  ///       {
  ///         "recipeId": "recipe_123",
  ///         "name": "Grilled Chicken Salad",
  ///         "calories": 450,
  ///         "difficulty": "easy"
  ///       },
  ///       { ... more suggestions ... }
  ///     ]
  ///   }
  /// }
  /// ```
  ///
  /// Returns:
  /// - List<Map<String, dynamic>>: Array of recipe suggestions
  ///
  /// Throws:
  /// - Exception: If success != true or endpoint fails
  ///
  /// Usage:
  /// ```dart
  /// final suggestions = await client.getReplacementSuggestions(
  ///   'plan_001',
  ///   'item_123',
  /// );
  /// // Show suggestions in UI for user to choose from
  /// ```
  Future<List<Map<String, dynamic>>> getReplacementSuggestions(
    String planId,
    String itemId,
  ) async {
    try {
      final url = '$baseUrl/api/meal-plans/$planId/items/$itemId/suggestions';
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          final suggestionsData = data['data'] as Map<String, dynamic>;
          final suggestions = (suggestionsData['suggestions'] as List?)
                  ?.map((e) => e as Map<String, dynamic>)
                  .toList() ??
              [];
          return suggestions;
        } else {
          throw Exception(data['message'] ?? 'Failed to get suggestions');
        }
      } else {
        throw Exception('Failed to get replacement suggestions');
      }
    } catch (e) {
      debugPrint('Error getting replacement suggestions: $e');
      throw Exception('Failed to get replacement suggestions: $e');
    }
  }

  /// 🔄 Replace a meal in meal plan with alternative recipe
  ///
  /// Endpoint: PATCH /api/meal-plans/:planId/items/:itemId/replace
  ///
  /// Replaces selected meal with new recipe
  /// Updates nutritional values accordingly
  /// Returns updated MealPlanItemModel
  ///
  /// URL Parameters:
  /// - planId: ID of the meal plan
  /// - itemId: ID of the meal item to replace
  ///
  /// Request Body:
  /// ```json
  /// {
  ///   "newRecipeId": "recipe_456",
  ///   "reason": "disliked" | "allergy" | "preference" | null
  /// }
  /// ```
  ///
  /// Response Data:
  /// - Updated MealPlanItemModel with new recipe
  ///
  /// Success Response Example:
  /// ```json
  /// {
  ///   "success": true,
  ///   "data": {
  ///     "_id": "item_001",
  ///     "recipeId": { ... new recipe ... },
  ///     "mealType": "breakfast",
  ///     "calories": 520,
  ///     ...
  ///   }
  /// }
  /// ```
  ///
  /// Returns:
  /// - MealPlanItemModel: Updated meal item with new recipe
  ///
  /// Throws:
  /// - Exception: If replacement fails
  ///
  /// Usage:
  /// ```dart
  /// final updatedMeal = await client.replaceMeal(
  ///   'plan_001',
  ///   'item_123',
  ///   'new_recipe_456',
  ///   'allergy',
  /// );
  /// print('Meal replaced: ${updatedMeal.recipeName}');
  /// ```
  Future<MealPlanItemModel> replaceMeal(
    String planId,
    String itemId,
    String newRecipeId,
    String? reason,
  ) async {
    try {
      final url = '$baseUrl/api/meal-plans/$planId/items/$itemId/replace';
      final response = await _dio.patch(
        url,
        data: {'newRecipeId': newRecipeId, 'reason': reason},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          final itemData = data['data'] as Map<String, dynamic>;
          return MealPlanItemModel.fromJson(itemData);
        } else {
          throw Exception(data['message'] ?? 'Failed to replace meal');
        }
      } else {
        throw Exception('Failed to replace meal');
      }
    } catch (e) {
      debugPrint('Error replacing meal: $e');
      throw Exception('Failed to replace meal: $e');
    }
  }

  /// ⭐ Rate a meal (1-5 stars)
  ///
  /// Endpoint: POST /api/meal-plans/:planId/items/:itemId/rate
  ///
  /// User rates meal after trying it
  /// Rating is used for future AI optimization
  /// Higher ratings = AI learns what user likes
  /// Lower ratings = flag for potential replacement
  ///
  /// URL Parameters:
  /// - planId: ID of the meal plan
  /// - itemId: ID of the meal item to rate
  ///
  /// Request Body:
  /// ```json
  /// {
  ///   "rating": 4
  /// }
  /// ```
  ///
  /// Rating Scale:
  /// - 5: Love it! (excellent meal, good fit)
  /// - 4: Good (decent meal, wouldn't change)
  /// - 3: Neutral (okay but not special)
  /// - 2: Dislike (wouldn't choose again)
  /// - 1: Hate it (definitely replace)
  ///
  /// Response Data:
  /// - Updated MealPlanItemModel with rating set
  ///
  /// Returns:
  /// - MealPlanItemModel: Updated meal item with rating
  ///
  /// Throws:
  /// - Exception: If rating fails
  ///
  /// Usage:
  /// ```dart
  /// final rated = await client.rateMeal(
  ///   'plan_001',
  ///   'item_123',
  ///   5, // Love it!
  /// );
  /// print('Meal rated: ${rated.userRating} stars');
  /// ```
  Future<MealPlanItemModel> rateMeal(
    String planId,
    String itemId,
    int rating,
  ) async {
    try {
      final url = '$baseUrl/api/meal-plans/$planId/items/$itemId/rate';
      final response = await _dio.post(url, data: {'rating': rating});

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          final itemData = data['data'] as Map<String, dynamic>;
          return MealPlanItemModel.fromJson(itemData);
        } else {
          throw Exception(data['message'] ?? 'Failed to rate meal');
        }
      } else {
        throw Exception('Failed to rate meal');
      }
    } catch (e) {
      debugPrint('Error rating meal: $e');
      throw Exception('Failed to rate meal: $e');
    }
  }

  /// 🔍 Get optimization suggestions for meal plan
  ///
  /// Endpoint: GET /api/meal-plans/:planId/optimization-suggestions
  ///
  /// Analyzes current plan and suggests improvements:
  /// - Lower-rated meals that could be replaced
  /// - Duplicate ingredients across meals (could consolidate)
  /// - Variety improvements
  /// - Macro imbalances
  ///
  /// URL Parameters:
  /// - planId: ID of the meal plan to analyze
  ///
  /// Response Structure:
  /// ```json
  /// {
  ///   "success": true,
  ///   "data": {
  ///     "mealsToReplace": [
  ///       {
  ///         "itemId": "item_001",
  ///         "recipeName": "Salmon",
  ///         "rating": 2,
  ///         "reason": "low_rating"
  ///       }
  ///     ],
  ///     "varietyIssues": [ ... ],
  ///     "ingredientConsolidation": { ... }
  ///   }
  /// }
  /// ```
  ///
  /// Returns:
  /// - Raw optimization data for display
  ///
  /// Throws:
  /// - Exception: If analysis fails
  ///
  /// Usage:
  /// ```dart
  /// final suggestions = await client.getOptimizationSuggestions(planId);
  /// // Show suggestions to user before optimization
  /// ```
  Future<Map<String, dynamic>> getOptimizationSuggestions(String planId) async {
    try {
      final url = '$baseUrl/api/meal-plans/$planId/optimization-suggestions';
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>;
        } else {
          throw Exception(
            data['message'] ?? 'Failed to get optimization suggestions',
          );
        }
      } else {
        throw Exception('Failed to get optimization suggestions');
      }
    } catch (e) {
      debugPrint('Error getting optimization suggestions: $e');
      throw Exception('Failed to get optimization suggestions: $e');
    }
  }

  /// 🚀 Optimize entire meal plan
  ///
  /// Endpoint: POST /api/meal-plans/:planId/optimize
  ///
  /// AI analyzes and improves entire meal plan:
  /// 1. Replaces low-rated meals
  /// 2. Increases variety
  /// 3. Balances macronutrients
  /// 4. Maintains calorie targets
  /// 5. Respects locked meals (user favorites)
  ///
  /// URL Parameters:
  /// - planId: ID of the meal plan to optimize
  ///
  /// Request Body: None
  ///
  /// Response Data:
  /// - Raw optimization result (caller typically doesn't use directly)
  /// - UI usually triggers refetch of updated plan
  ///
  /// Timeline:
  /// - Takes 5-30 seconds depending on plan size
  /// - Keeps meal distribution (breakfast/lunch/dinner)
  /// - Maintains day-by-day structure
  ///
  /// Returns:
  /// - Optimization result metadata
  ///
  /// Throws:
  /// - Exception: If optimization fails
  ///
  /// Usage:
  /// ```dart
  /// // Show confirmation dialog to user first!
  /// final confirmed = await showDialog(
  ///   context: context,
  ///   builder: (ctx) => AlertDialog(
  ///     title: Text('Optimize meal plan?'),
  ///     actions: [
  ///       TextButton(
  ///         onPressed: () => Navigator.pop(ctx, true),
  ///         child: Text('Optimize'),
  ///       ),
  ///     ],
  ///   ),
  /// );
  ///
  /// if (confirmed) {
  ///   await client.optimizeMealPlan(planId);
  ///   // Refetch plan to show optimized version
  ///   final updatedPlan = await client.fetchLatestMealPlan();
  /// }
  /// ```
  Future<Map<String, dynamic>> optimizeMealPlan(String planId) async {
    try {
      final url = '$baseUrl/api/meal-plans/$planId/optimize';
      final response = await _dio.post(url);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>;
        } else {
          throw Exception(data['message'] ?? 'Failed to optimize meal plan');
        }
      } else {
        throw Exception('Failed to optimize meal plan');
      }
    } catch (e) {
      debugPrint('Error optimizing meal plan: $e');
      throw Exception('Failed to optimize meal plan: $e');
    }
  }

  /// 👁️ Generate meal plan preview (no database save yet)
  ///
  /// Endpoint: POST /api/ai/meal-plan/preview
  ///
  /// Generates preview meal plan based on user health profile
  /// No save to database happens yet
  /// Allows user to review/modify before committing
  ///
  /// User Profile Parameters:
  /// - userId: User ID for personalization
  /// - age: User age (affects calorie needs)
  /// - gender: 'male' or 'female' (affects macros)
  /// - heightCm: Height in centimeters (BMR calculation)
  /// - weightKg: Current weight in kg
  /// - goalWeightKg: Target weight in kg
  /// - healthGoals: 'weight_loss' | 'muscle_gain' | 'maintain' | 'performance'
  /// - activityLevel: 'sedentary' | 'light' | 'moderate' | 'active' | 'very_active'
  /// - dietTypes: Array of diet types ['vegetarian', 'keto', 'low_sodium']
  /// - allergies: Array of allergens to avoid ['peanuts', 'shellfish']
  /// - dislikedIngredients: Array of ingredients user doesn't like
  /// - days: Number of days to generate (3, 7, 14, 30)
  ///
  /// Request Body:
  /// ```json
  /// {
  ///   "userId": "user_123",
  ///   "age": 28,
  ///   "gender": "male",
  ///   "height_cm": 180,
  ///   "weight_kg": 85,
  ///   "goal_weight_kg": 80,
  ///   "health_goals": "weight_loss",
  ///   "activity_level": "moderate",
  ///   "dietTypes": ["vegetarian"],
  ///   "allergies": ["peanuts"],
  ///   "disliked_ingredients": ["onions"],
  ///   "days": 7
  /// }
  /// ```
  ///
  /// Response Data:
  /// - Raw preview data (JSON) - user can modify before saving
  /// - Not yet a MealPlanGenerationResult (that comes after save)
  ///
  /// Returns:
  /// - Map<String, dynamic>: Preview data for modification
  ///
  /// Throws:
  /// - Exception: If generation fails
  ///
  /// Workflow:
  /// 1. User creates profile / customizes preferences
  /// 2. App calls generateMealPlanPreview()
  /// 3. User sees preview and can:
  ///    - Replace meals they don't like
  ///    - Adjust quantities
  ///    - Modify macros
  /// 4. User clicks "Save" → calls saveMealPlanFromPreview()
  /// 5. Backend saves to database and returns official MealPlanGenerationResult
  ///
  /// Usage:
  /// ```dart
  /// final preview = await client.generateMealPlanPreview(
  ///   userId: auth.user.id,
  ///   age: 28,
  ///   gender: 'male',
  ///   heightCm: 180,
  ///   weightKg: 85,
  ///   goalWeightKg: 80,
  ///   healthGoals: 'weight_loss',
  ///   activityLevel: 'moderate',
  ///   dietTypes: ['vegetarian'],
  ///   allergies: [],
  ///   dislikedIngredients: ['onions'],
  ///   days: 7,
  /// );
  /// // Show preview to user for modification
  /// ```
  Future<Map<String, dynamic>> generateMealPlanPreview({
    required String userId,
    required int age,
    required String gender,
    required double heightCm,
    required double weightKg,
    required double goalWeightKg,
    required String healthGoals,
    required String activityLevel,
    required List<String> dietTypes,
    required List<String> allergies,
    required List<String> dislikedIngredients,
    required int days,
  }) async {
    final url = '$baseUrl/api/ai/meal-plan/preview';
    final res = await _dio.post(
      url,
      data: {
        'userId': userId,
        'age': age,
        'gender': gender,
        'height_cm': heightCm,
        'weight_kg': weightKg,
        'goal_weight_kg': goalWeightKg,
        'health_goals': healthGoals,
        'activity_level': activityLevel,
        'dietTypes': dietTypes,
        'allergies': allergies,
        'disliked_ingredients': dislikedIngredients,
        'days': days,
      },
    );

    final data = res.data as Map<String, dynamic>;
    if (data['success'] != true) {
      debugPrint('generateMealPlanPreview error: ${data['message']}');
      throw Exception(
        data['message'] ?? 'Failed to generate meal plan preview',
      );
    }

    return data['data'] as Map<String, dynamic>;
  }

  /// 💾 Save modified meals from preview to database
  ///
  /// Endpoint: POST /api/ai/meal-plan/save-preview
  ///
  /// Saves user-modified preview as official meal plan
  /// Creates database record and associates with user
  /// Returns complete MealPlanGenerationResult
  ///
  /// Parameters:
  /// - userId: User ID (from auth)
  /// - originalAIMealPlan: Original preview data (before modifications)
  /// - mealPlanOptions: User's preferences/settings
  /// - modifiedMeals: User's modifications to the preview
  ///   (e.g., swapped recipes, adjusted quantities)
  ///
  /// Request Body:
  /// ```json
  /// {
  ///   "userId": "user_123",
  ///   "originalAIMealPlan": { ... original preview ... },
  ///   "mealPlanOptions": { ... user preferences ... },
  ///   "modifiedMeals": {
  ///     "replaced": {
  ///       "item_001": "new_recipe_456"
  ///     },
  ///     "modified": {
  ///       "item_002": { "servings": 3 }
  ///     }
  ///   }
  /// }
  /// ```
  ///
  /// Response Data:
  /// - Complete MealPlanGenerationResult (saved to DB)
  /// - Ready to display and sync to grocery list
  ///
  /// Success Response Example:
  /// ```json
  /// {
  ///   "success": true,
  ///   "data": {
  ///     "mealPlan": { "_id": "new_plan_id", "days": 7, ... },
  ///     "items": [ ... 21 meals ... ],
  ///     "summary": { ... }
  ///   }
  /// }
  /// ```
  ///
  /// Returns:
  /// - MealPlanGenerationResult: The saved meal plan
  ///
  /// Throws:
  /// - Exception: If save fails
  ///
  /// Workflow After Save:
  /// 1. Meal plan is saved to database
  /// 2. App typically calls _syncMealPlanToGroceryList()
  /// 3. Ingredients extracted and added to grocery list
  /// 4. User gets success notification
  ///
  /// Usage:
  /// ```dart
  /// // User customized preview, now save it
  /// final saved = await client.saveMealPlanFromPreview(
  ///   userId: auth.user.id,
  ///   originalAIMealPlan: previewData,
  ///   mealPlanOptions: userOptions,
  ///   modifiedMeals: userModifications,
  /// );
  ///
  /// print('Saved meal plan: ${saved.mealPlan.id}');
  /// print('Contains ${saved.items.length} meals');
  ///
  /// // Now sync to grocery list
  /// await syncMealPlanToGrocery(saved);
  /// ```
  Future<MealPlanGenerationResult> saveMealPlanFromPreview({
    required String userId,
    required Map<String, dynamic> originalAIMealPlan,
    required Map<String, dynamic> mealPlanOptions,
    required Map<String, dynamic> modifiedMeals,
  }) async {
    final url = '$baseUrl/api/ai/meal-plan/save-preview';
    final res = await _dio.post(
      url,
      data: {
        'userId': userId,
        'originalAIMealPlan': originalAIMealPlan,
        'mealPlanOptions': mealPlanOptions,
        'modifiedMeals': modifiedMeals,
      },
    );

    final data = res.data as Map<String, dynamic>;
    if (data['success'] != true) {
      debugPrint('saveMealPlanFromPreview error: ${data['message']}');
      throw Exception(data['message'] ?? 'Failed to save meal plan');
    }

    return MealPlanGenerationResult.fromJson(
      data['data'] as Map<String, dynamic>,
    );
  }
}
