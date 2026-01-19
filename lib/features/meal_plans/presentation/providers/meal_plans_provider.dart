import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/meal_plan.dart';

/// State for meal plans.
class MealPlansState {
  final bool isLoading;
  final MealPlan? dailyPlan;
  final List<MealPlan> weeklyPlans;
  final bool isGenerating;
  final String? errorMessage;

  const MealPlansState({
    this.isLoading = false,
    this.dailyPlan,
    this.weeklyPlans = const [],
    this.isGenerating = false,
    this.errorMessage,
  });

  MealPlansState copyWith({
    bool? isLoading,
    MealPlan? dailyPlan,
    List<MealPlan>? weeklyPlans,
    bool? isGenerating,
    String? errorMessage,
  }) {
    return MealPlansState(
      isLoading: isLoading ?? this.isLoading,
      dailyPlan: dailyPlan ?? this.dailyPlan,
      weeklyPlans: weeklyPlans ?? this.weeklyPlans,
      isGenerating: isGenerating ?? this.isGenerating,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Meal plans notifier.
class MealPlansNotifier extends StateNotifier<MealPlansState> {
  MealPlansNotifier() : super(const MealPlansState());

  /// Loads the daily meal plan.
  Future<void> loadDailyPlan(DateTime date) async {
    state = state.copyWith(isLoading: true);
    // TODO: Implement using GetDailyMealPlanUseCase
  }

  /// Loads the weekly meal plan.
  Future<void> loadWeeklyPlan(DateTime startDate) async {
    state = state.copyWith(isLoading: true);
    // TODO: Implement using GetWeeklyMealPlanUseCase
  }

  /// Generates an AI meal plan.
  Future<void> generateMealPlan({
    required DateTime date,
    required String planType,
    int? targetCalories,
  }) async {
    state = state.copyWith(isGenerating: true);
    // TODO: Implement using GenerateMealPlanUseCase
  }
}

/// Provider for meal plans state.
final mealPlansProvider =
    StateNotifierProvider<MealPlansNotifier, MealPlansState>((ref) {
  return MealPlansNotifier();
});
