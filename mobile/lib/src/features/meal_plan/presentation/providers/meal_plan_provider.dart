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
    MealPlanGenerationResult? result,
    bool clearResult = false,
  }) {
    return MealPlanState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      result: clearResult ? null : (result ?? this.result),
    );
  }
}

class MealPlanNotifier extends StateNotifier<MealPlanState> {
  final MealPlanApiClient _apiClient;

  MealPlanNotifier(this._apiClient) : super(const MealPlanState());

  Future<void> loadLatestMealPlan() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _apiClient.fetchLatestMealPlan();
      // Small delay for smooth UI transition
      await Future.delayed(const Duration(milliseconds: 300));
      state = state.copyWith(isLoading: false, result: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> generateMealPlan({required int days}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Generate new meal plan
      await _apiClient.generateMealPlan(days: days);
      // Wait for server to process
      await Future.delayed(const Duration(milliseconds: 500));
      // Reload latest meal plan from server (ensures complete data)
      final result = await _apiClient.fetchLatestMealPlan();
      // Small delay for smooth UI transition
      await Future.delayed(const Duration(milliseconds: 300));
      state = state.copyWith(isLoading: false, result: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteAllMealPlans() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _apiClient.deleteAllMealPlans();
      await Future.delayed(const Duration(milliseconds: 200));
      state = state.copyWith(isLoading: false, clearResult: true);
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
    state = state.copyWith(isLoading: true, error: null);
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
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _apiClient.optimizeMealPlan(mealPlanId);
      // Reload the optimized meal plan
      await Future.delayed(const Duration(milliseconds: 500));
      final result = await _apiClient.fetchLatestMealPlan();
      await Future.delayed(const Duration(milliseconds: 300));
      state = state.copyWith(isLoading: false, result: result);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to optimize meal plan: ${e.toString()}',
      );
    }
  }

  /// Mark a meal as eaten
  void markMealAsEaten(String mealId, DateTime eatenDate) {
    if (state.result != null) {
      final updatedItems = state.result!.items.map((item) {
        if (item.id == mealId) {
          return MealPlanItemModel(
            id: item.id,
            mealType: item.mealType,
            servings: item.servings,
            calories: item.calories,
            protein: item.protein,
            carbohydrates: item.carbohydrates,
            fat: item.fat,
            dayIndex: item.dayIndex,
            recipeName: item.recipeName,
            recipeImageUrl: item.recipeImageUrl,
            userRating: item.userRating,
            userAction: item.userAction,
            isLocked: item.isLocked,
            isEaten: true,
            eatenDate: eatenDate,
          );
        }
        return item;
      }).toList();

      final newResult = MealPlanGenerationResult(
        mealPlan: state.result!.mealPlan,
        items: updatedItems,
        summary: state.result!.summary,
      );
      state = state.copyWith(result: newResult);
    }
  }

  /// Mark a meal as uneaten
  void markMealAsUneaten(String mealId) {
    if (state.result != null) {
      final updatedItems = state.result!.items.map((item) {
        if (item.id == mealId) {
          return MealPlanItemModel(
            id: item.id,
            mealType: item.mealType,
            servings: item.servings,
            calories: item.calories,
            protein: item.protein,
            carbohydrates: item.carbohydrates,
            fat: item.fat,
            dayIndex: item.dayIndex,
            recipeName: item.recipeName,
            recipeImageUrl: item.recipeImageUrl,
            userRating: item.userRating,
            userAction: item.userAction,
            isLocked: item.isLocked,
            isEaten: false,
            eatenDate: null,
          );
        }
        return item;
      }).toList();

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
