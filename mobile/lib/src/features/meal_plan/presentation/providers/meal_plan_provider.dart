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
}

final mealPlanNotifierProvider =
    StateNotifierProvider<MealPlanNotifier, MealPlanState>((ref) {
      final apiClient = ref.watch(mealPlanApiClientProvider);
      return MealPlanNotifier(apiClient);
    });
