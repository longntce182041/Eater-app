import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/meal_plan_api_client.dart';
import '../../domain/meal_plan_models.dart';

/// 📋 MEAL PLAN STATE MODEL
///
/// Manages the complete state of meal plan feature
/// Holds loading status, errors, and current meal plan data
/// Used by MealPlanNotifier to manage state updates
///
/// Fields:
/// - isLoading: API request in progress (show spinner)
/// - error: Latest error message (null if no error)
/// - result: Current meal plan data (null if not loaded)
///
/// State Transitions:
/// ```
/// Initial: loading=false, error=null, result=null
///   ↓ (User taps generate)
/// Loading: loading=true, error=null, result=null
///   ↓ (Success)
/// Loaded: loading=false, error=null, result=MealPlan
///   ↓ (User rates meal)
/// Updated: loading=false, error=null, result=Updated MealPlan
///   ↓ (User taps delete)
/// Deleted: loading=false, error=null, result=null
/// ```
///
/// Error Handling:
/// ```
/// Loaded: loading=false, error=null, result=MealPlan
///   ↓ (API error occurs)
/// Error State: loading=false, error="Network failed", result=MealPlan (previous)
///   ↓ (User taps retry)
/// Loading: loading=true, error=null, result=MealPlan (previous)
/// ```
class MealPlanState {
  final bool isLoading;
  final String? error;
  final MealPlanGenerationResult? result;

  const MealPlanState({this.isLoading = false, this.error, this.result});

  /// ✏️ Create modified copy with specified fields changed
  ///
  /// Pattern for immutable state updates
  /// Returns new MealPlanState instance
  ///
  /// Special Handling:
  /// - clearError=true: Clears error field even if new error not provided
  /// - clearResult=true: Clears result field
  /// - Allows clearing without knowing current values
  ///
  /// Common Patterns:
  /// ```dart
  /// // When starting API call
  /// state = state.copyWith(isLoading: true, clearError: true);
  ///
  /// // When API succeeds
  /// state = state.copyWith(isLoading: false, result: newPlan);
  ///
  /// // When API fails
  /// state = state.copyWith(
  ///   isLoading: false,
  ///   error: 'Failed to load',
  /// );
  ///
  /// // When clearing error for retry
  /// state = state.copyWith(clearError: true);
  /// ```
  MealPlanState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    MealPlanGenerationResult? result,
    bool clearResult = false,
  }) {
    return MealPlanState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      result: clearResult ? null : (result ?? this.result),
    );
  }
}

/// 🎯 MEAL PLAN STATE NOTIFIER
///
/// Business logic for meal plan feature
/// Manages API calls and state updates
/// Follows Riverpod StateNotifier pattern
///
/// Responsibilities:
/// 1. Fetch meal plans from API
/// 2. Generate new meal plans
/// 3. Modify meals (rate, replace, etc.)
/// 4. Delete plans
/// 5. Optimize meal plans
/// 6. Track meal eating status
///
/// State Management:
/// - Starts with empty MealPlanState
/// - Updates state on API responses
/// - Handles errors gracefully
/// - Prevents state corruption
///
/// Architecture:
/// ```
/// UI (MealPlanPage)
///   ↓
/// mealPlanNotifierProvider (Riverpod Provider)
///   ↓
/// MealPlanNotifier (this class)
///   ├─ State: MealPlanState (current plan data)
///   ├─ API: MealPlanApiClient (HTTP requests)
///   └─ Methods:
///      ├─ loadLatestMealPlan()
///      ├─ generateMealPlan()
///      ├─ rateMeal()
///      ├─ replaceMeal()
///      ├─ optimizeMealPlan()
///      └─ ... more methods
/// ```
class MealPlanNotifier extends StateNotifier<MealPlanState> {
  final MealPlanApiClient _apiClient;

  MealPlanNotifier(this._apiClient) : super(const MealPlanState());

  /// 📥 Load the latest meal plan from API
  ///
  /// Fetches the most recently saved plan for current user
  /// Updates state with loading/success/error states
  /// Safe to call multiple times (idempotent)
  ///
  /// State Flow:
  /// ```
  /// Initial
  ///   ↓ (Call loadLatestMealPlan)
  /// Loading: isLoading=true, error=null
  ///   ↓ (API returns data)
  /// Success: isLoading=false, result=MealPlan
  ///   OR
  /// Error: isLoading=false, error="Network error"
  /// ```
  ///
  /// Usage:
  /// ```dart
  /// // On screen init or retry
  /// await notifier.loadLatestMealPlan();
  /// // state now has result or error
  /// ```
  Future<void> loadLatestMealPlan() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _apiClient.fetchLatestMealPlan();
      state = state.copyWith(isLoading: false, result: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 🤖 Generate new AI meal plan
  ///
  /// Creates fresh meal plan based on user preferences
  /// Generator determines meals, portions, macros
  /// Automatically loads plan after generation
  ///
  /// Parameters:
  /// - days: Number of days (3, 7, 14, 30, etc.)
  ///
  /// Process:
  /// 1. Call API to generate plan
  /// 2. Backend creates plan in database
  /// 3. Fetch latest to get complete data
  ///    (ensures consistent state with backend)
  ///
  /// Why reload after generate:
  /// - Backend may add IDs, timestamps, defaults
  /// - Ensures state matches database exactly
  /// - Prevents stale data in UI
  ///
  /// Usage:
  /// ```dart
  /// await notifier.generateMealPlan(days: 7);
  /// // state.result now has 7-day meal plan
  /// ```
  Future<void> generateMealPlan({required int days}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // Generate new meal plan
      await _apiClient.generateMealPlan(days: days);
      // Reload latest meal plan from server (ensures complete data)
      final result = await _apiClient.fetchLatestMealPlan();
      state = state.copyWith(isLoading: false, result: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 🗑️ Delete all meal plans for user
  ///
  /// Destructive operation - removes ALL saved plans
  /// UI should require confirmation beforehand
  /// Clears current state after deletion
  ///
  /// ⚠️ Warning:
  /// - This is permanent and cannot be undone
  /// - Should only be called after user confirms
  /// - Consider soft delete on backend for recovery
  ///
  /// State After Deletion:
  /// ```
  /// result: null (clears the plan)
  /// error: null (success, no error)
  /// isLoading: false (done)
  /// ```
  ///
  /// Usage:
  /// ```dart
  /// // Only after user confirms!
  /// final confirmed = await showConfirmDialog(
  ///   'Delete all meal plans? This cannot be undone.'
  /// );
  /// if (confirmed) {
  ///   await notifier.deleteAllMealPlans();
  /// }
  /// ```
  Future<void> deleteAllMealPlans() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _apiClient.deleteAllMealPlans();
      state =
          state.copyWith(isLoading: false, clearResult: true, clearError: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// ⭐ Rate a meal in the current meal plan
  ///
  /// User rates meal after eating (1-5 stars)
  /// Provides feedback for AI optimization
  /// Updates local state immediately
  ///
  /// Rating Scale:
  /// - 5: Love it (excellent meal)
  /// - 4: Good (solid meal)
  /// - 3: Okay (neutral)
  /// - 2: Dislike (wouldn't choose again)
  /// - 1: Hate it (definitely replace)
  ///
  /// Parameters:
  /// - mealPlanId: ID of the meal plan
  /// - itemId: ID of the specific meal to rate
  /// - rating: 1-5 star rating
  ///
  /// State Update:
  /// - API updates meal with rating
  /// - Local state updated with new meal data
  /// - UI reflects rating immediately
  ///
  /// Example:
  /// ```dart
  /// // User taps 5-star button
  /// await notifier.rateMeal(
  ///   mealPlanId: plan.id,
  ///   itemId: meal.id,
  ///   rating: 5,
  /// );
  /// // Meal now shows as 5-star in UI
  /// ```
  Future<void> rateMeal(String mealPlanId, String itemId, int rating) async {
    try {
      final updatedItem = await _apiClient.rateMeal(mealPlanId, itemId, rating);
      if (state.result != null) {
        // Update the item in the current result
        final updatedItems = state.result!.items
            .map((item) => item.id == itemId ? updatedItem : item)
            .toList();
        final newResult = MealPlanGenerationResult(
          mealPlan: state.result!.mealPlan,
          items: updatedItems,
          summary: state.result!.summary,
        );
        state = state.copyWith(result: newResult);
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to rate meal: ${e.toString()}');
    }
  }

  /// 🔄 Replace a meal in the current meal plan
  ///
  /// Swaps out meal with alternative recipe
  /// Gets new recipe from suggestion list
  /// Updates nutritional values automatically
  ///
  /// Reasons for Replacement:
  /// - Don't like dish
  /// - Allergy/dietary restriction
  /// - Ingredient availability
  /// - Personal preference
  ///
  /// Parameters:
  /// - mealPlanId: ID of meal plan
  /// - itemId: ID of meal to replace
  /// - newRecipeId: ID of new recipe
  /// - reason: Why replacing (optional, for analytics)
  ///
  /// Backend Process:
  /// 1. Validate new recipe exists
  /// 2. Check nutritional compatibility
  /// 3. Update meal with new recipe
  /// 4. Recalculate macro if needed
  /// 5. Return updated meal
  ///
  /// State Update:
  /// - Updates specific meal in plan
  /// - Keeps other meals unchanged
  /// - Updates UI immediately
  ///
  /// Example:
  /// ```dart
  /// // User doesn't like salmon, pick chicken
  /// await notifier.replaceMeal(
  ///   planId,
  ///   mealId,
  ///   newRecipeId: 'grilled_chicken_id',
  ///   reason: 'allergy',
  /// );
  /// // UI shows new chicken recipe
  /// ```
  Future<void> replaceMeal(
    String mealPlanId,
    String itemId,
    String newRecipeId,
    String? reason,
  ) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final updatedItem = await _apiClient.replaceMeal(
        mealPlanId,
        itemId,
        newRecipeId,
        reason,
      );
      if (state.result != null) {
        // Update the item in the current result
        final updatedItems = state.result!.items
            .map((item) => item.id == itemId ? updatedItem : item)
            .toList();
        final newResult = MealPlanGenerationResult(
          mealPlan: state.result!.mealPlan,
          items: updatedItems,
          summary: state.result!.summary,
        );
        state = state.copyWith(isLoading: false, result: newResult);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to replace meal: ${e.toString()}',
      );
    }
  }

  /// 🚀 Optimize entire meal plan
  ///
  /// AI analyzes plan and makes improvements:
  /// 1. Replaces low-rated meals
  /// 2. Increases variety (reduces repetition)
  /// 3. Balances macronutrients
  /// 4. Maintains calorie targets
  /// 5. Respects locked meals (user favorites)
  ///
  /// Optimization Algorithm:
  /// - Identifies meals with low user ratings
  /// - Checks for nutrient imbalances
  /// - Suggests/applies replacements
  /// - Recalculates totals
  /// - Takes ~10-30 seconds
  ///
  /// Parameters:
  /// - mealPlanId: ID of plan to optimize
  ///
  /// What Doesn't Change:
  /// - Number of days
  /// - Meal types (breakfast/lunch/dinner)
  /// - Day structure
  /// - Locked items
  ///
  /// Usage:
  /// ```dart
  /// // Show confirmation to user
  /// final confirmed = await showConfirmDialog(
  ///   'This will improve your meal plan. Continue?'
  /// );
  /// if (confirmed) {
  ///   await notifier.optimizeMealPlan(planId);
  ///   // Shows updated plan with improvements
  /// }
  /// ```
  Future<void> optimizeMealPlan(String mealPlanId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _apiClient.optimizeMealPlan(mealPlanId);
      // Reload the optimized meal plan
      final result = await _apiClient.fetchLatestMealPlan();
      state = state.copyWith(isLoading: false, result: result);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to optimize meal plan: ${e.toString()}',
      );
    }
  }

  /// 👁️ Generate meal plan preview (no database save yet)
  ///
  /// Creates plan preview based on user health profile
  /// User can review and modify before committing
  /// No database changes until saveMealPlanFromPreview called
  ///
  /// Parameters:
  /// - userId: User ID
  /// - age, gender, heightCm, weightKg, goalWeightKg: User profile
  /// - healthGoals: 'weight_loss' | 'muscle_gain' | 'maintain' | 'performance'
  /// - activityLevel: Sedentary to very active
  /// - dietTypes: Vegetarian, keto, etc.
  /// - allergies: List of allergens to avoid
  /// - dislikedIngredients: Ingredients user doesn't like
  /// - days: How many days to generate
  ///
  /// Returns:
  /// - Map with preview data (user can modify)
  /// - null if generation failed
  ///
  /// Workflow After Getting Preview:
  /// 1. Show preview to user
  /// 2. User can swap meals, adjust quantities
  /// 3. User clicks "Save"
  /// 4. App calls saveMealPlanFromPreview()
  ///
  /// Usage:
  /// ```dart
  /// final preview = await notifier.generateMealPlanPreview(
  ///   userId: auth.user.id,
  ///   age: 28,
  ///   gender: 'male',
  ///   ... other params ...
  /// );
  /// if (preview != null) {
  ///   showPreviewScreen(preview);
  /// }
  /// ```
  Future<Map<String, dynamic>?> generateMealPlanPreview({
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
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final previewData = await _apiClient.generateMealPlanPreview(
        userId: userId,
        age: age,
        gender: gender,
        heightCm: heightCm,
        weightKg: weightKg,
        goalWeightKg: goalWeightKg,
        healthGoals: healthGoals,
        activityLevel: activityLevel,
        dietTypes: dietTypes,
        allergies: allergies,
        dislikedIngredients: dislikedIngredients,
        days: days,
      );
      state = state.copyWith(isLoading: false);
      return previewData;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to generate preview: ${e.toString()}',
      );
      return null;
    }
  }

  /// 💾 Save modified meals from preview to database
  ///
  /// Persists user-modified meal plan to database
  /// Creates official MealPlanGenerationResult
  /// Typically followed by sync to grocery list
  ///
  /// Parameters:
  /// - userId: User ID (for ownership)
  /// - originalAIMealPlan: Original preview data
  /// - mealPlanOptions: User preferences
  /// - modifiedMeals: User's modifications
  ///   Example: { "replaced": { "item_1": "new_recipe_id" } }
  ///
  /// State After Save:
  /// - result: Full MealPlanGenerationResult (ready to use)
  /// - error: null (success)
  /// - isLoading: false (done)
  ///
  /// Typical Flow:
  /// 1. generateMealPlanPreview() → preview data
  /// 2. User modifies preview
  /// 3. User clicks "Save"
  /// 4. saveMealPlanFromPreview() → MealPlanGenerationResult
  /// 5. _syncMealPlanToGroceryList() → add to grocery list
  /// 6. Show success notification
  ///
  /// Usage:
  /// ```dart
  /// await notifier.saveMealPlanFromPreview(
  ///   userId: auth.user.id,
  ///   originalAIMealPlan: previewData,
  ///   mealPlanOptions: userOptions,
  ///   modifiedMeals: userChanges,
  /// );
  /// // state.result now has saved plan ready to use
  /// ```
  Future<void> saveMealPlanFromPreview({
    required String userId,
    required Map<String, dynamic> originalAIMealPlan,
    required Map<String, dynamic> mealPlanOptions,
    required Map<String, dynamic> modifiedMeals,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _apiClient.saveMealPlanFromPreview(
        userId: userId,
        originalAIMealPlan: originalAIMealPlan,
        mealPlanOptions: mealPlanOptions,
        modifiedMeals: modifiedMeals,
      );
      state = state.copyWith(isLoading: false, result: result);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to save meal plan: ${e.toString()}',
      );
    }
  }

  /// ✓ Mark a meal as eaten/consumed
  ///
  /// Updates meal's eating status to completed
  /// Records when user ate the meal
  /// Used for tracking nutrition progress
  ///
  /// Parameters:
  /// - itemId: ID of meal to mark eaten
  /// - eatenDate: When meal was eaten
  ///
  /// State Update:
  /// - Updates specific item's isEaten and eatenDate
  /// - Other meals unchanged
  /// - No API call (local state only)
  ///
  /// UI Effects:
  /// - Checkbox becomes checked
  /// - Meal may fade or show "eaten" badge
  /// - Progr updates to show meal as done
  ///
  /// Usage:
  /// ```dart
  /// // User taps checkbox after eating
  /// notifier.markMealAsEaten(
  ///   mealItem.id,
  ///   DateTime.now(),
  /// );
  /// // Meal shows as eaten in UI
  /// ```
  void markMealAsEaten(String itemId, DateTime eatenDate) {
    if (state.result != null) {
      final updatedItems = state.result!.items
          .map((item) => item.id == itemId
              ? item.copyWith(isEaten: true, eatenDate: eatenDate)
              : item)
          .toList();
      final newResult = MealPlanGenerationResult(
        mealPlan: state.result!.mealPlan,
        items: updatedItems,
        summary: state.result!.summary,
      );
      state = state.copyWith(result: newResult);
    }
  }

  /// ✗ Mark a meal as NOT eaten
  ///
  /// Clears eating status (undo)
  /// Removes eatenDate timestamp
  /// Used if user marks eaten by mistake
  ///
  /// Parameters:
  /// - itemId: ID of meal to unmark
  ///
  /// State Update:
  /// - Sets isEaten = false
  /// - Clears eatenDate
  /// - Other data unchanged
  ///
  /// Usage:
  /// ```dart
  /// // User unchecks checkbox
  /// notifier.markMealAsUneaten(mealItem.id);
  /// // Meal shows as pending/uneaten
  /// ```
  void markMealAsUneaten(String itemId) {
    if (state.result != null) {
      final updatedItems = state.result!.items
          .map((item) => item.id == itemId
              ? item.copyWith(isEaten: false, eatenDate: null)
              : item)
          .toList();
      final newResult = MealPlanGenerationResult(
        mealPlan: state.result!.mealPlan,
        items: updatedItems,
        summary: state.result!.summary,
      );
      state = state.copyWith(result: newResult);
    }
  }
}

/// 📍 RIVERPOD PROVIDER FOR MEAL PLAN STATE
///
/// Creates and provides MealPlanNotifier instance
/// Manages automatic injection of dependencies
/// Provides state watching for UI widgets
///
/// Dependencies:
/// - mealPlanApiClientProvider: HTTP client
///
/// Usage in UI:
/// ```dart
/// // In StatefulWidget build()
/// final mealPlanState = ref.watch(mealPlanNotifierProvider);
///
/// // Get notifier for calling methods
/// final notifier = ref.read(mealPlanNotifierProvider.notifier);
/// notifier.loadLatestMealPlan();
/// ```
final mealPlanNotifierProvider =
    StateNotifierProvider<MealPlanNotifier, MealPlanState>((ref) {
  final apiClient = ref.watch(mealPlanApiClientProvider);
  return MealPlanNotifier(apiClient);
});
