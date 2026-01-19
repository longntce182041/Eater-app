import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/meal_plan.dart';

class MealPlanState {
  final bool isLoading;
  final MealPlan? mealPlan;
  final String? error;

  MealPlanState({
    this.isLoading = false,
    this.mealPlan,
    this.error,
  });

  MealPlanState copyWith({
    bool? isLoading,
    MealPlan? mealPlan,
    String? error,
  }) {
    return MealPlanState(
      isLoading: isLoading ?? this.isLoading,
      mealPlan: mealPlan ?? this.mealPlan,
      error: error ?? this.error,
    );
  }
}

class MealPlanNotifier extends StateNotifier<MealPlanState> {
  MealPlanNotifier() : super(MealPlanState());

  Future<void> loadDailyMealPlan(String userId, DateTime date) async {
    // TODO: Implement load daily meal plan
  }

  Future<void> loadWeeklyMealPlan(String userId, DateTime startDate) async {
    // TODO: Implement load weekly meal plan
  }

  Future<void> generateMealPlan(String userId, String planType, Map<String, dynamic> preferences) async {
    // TODO: Implement generate meal plan
  }
}

final mealPlanProvider = StateNotifierProvider<MealPlanNotifier, MealPlanState>((ref) {
  return MealPlanNotifier();
});
