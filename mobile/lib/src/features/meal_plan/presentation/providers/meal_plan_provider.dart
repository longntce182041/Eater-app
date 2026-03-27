import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/meal_plan_api_client.dart';
import '../../domain/meal_plan_models.dart';

class MealPlanState {
  final bool isLoading;
  final String? error;
  final MealPlanGenerationResult? result;

  const MealPlanState({this.isLoading = false, this.error, this.result});

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

class MealPlanNotifier extends StateNotifier<MealPlanState> {
  final MealPlanApiClient _apiClient;

  MealPlanNotifier(this._apiClient) : super(const MealPlanState());

  Future<void> loadLatestMealPlan() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _apiClient.fetchLatestMealPlan();
      state = state.copyWith(isLoading: false, result: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

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

  /// Rate a meal in the current meal plan
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

  /// Replace a meal in the current meal plan
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

  /// Optimize the entire meal plan
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

  /// Generate meal plan preview (no database save yet)
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

  /// Save modified meals from preview to database
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

  /// Mark a meal as eaten
  void markMealAsEaten(String itemId, DateTime eatenDate) {
    if (state.result != null) {
      final updatedItems = state.result!.items
          .map((item) =>
              item.id == itemId
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

  /// Mark a meal as not eaten
  void markMealAsUneaten(String itemId) {
    if (state.result != null) {
      final updatedItems = state.result!.items
          .map((item) =>
              item.id == itemId
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

final mealPlanNotifierProvider =
    StateNotifierProvider<MealPlanNotifier, MealPlanState>((ref) {
  final apiClient = ref.watch(mealPlanApiClientProvider);
  return MealPlanNotifier(apiClient);
});
