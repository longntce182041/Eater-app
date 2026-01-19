import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/meal_log.dart';
import '../../domain/entities/nutrition_summary.dart';

/// State for meal logging.
class MealLoggingState {
  final bool isLoading;
  final List<MealLog> mealLogs;
  final NutritionSummary? nutritionSummary;
  final DateTime selectedDate;
  final String? errorMessage;

  MealLoggingState({
    this.isLoading = false,
    this.mealLogs = const [],
    this.nutritionSummary,
    DateTime? selectedDate,
    this.errorMessage,
  }) : selectedDate = selectedDate ?? DateTime.now();

  MealLoggingState copyWith({
    bool? isLoading,
    List<MealLog>? mealLogs,
    NutritionSummary? nutritionSummary,
    DateTime? selectedDate,
    String? errorMessage,
  }) {
    return MealLoggingState(
      isLoading: isLoading ?? this.isLoading,
      mealLogs: mealLogs ?? this.mealLogs,
      nutritionSummary: nutritionSummary ?? this.nutritionSummary,
      selectedDate: selectedDate ?? this.selectedDate,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Meal logging notifier.
class MealLoggingNotifier extends StateNotifier<MealLoggingState> {
  MealLoggingNotifier() : super(MealLoggingState());

  /// Changes the selected date.
  void changeDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
    loadMealLogs();
    loadNutritionSummary();
  }

  /// Loads meal logs for the selected date.
  Future<void> loadMealLogs() async {
    state = state.copyWith(isLoading: true);
    // TODO: Implement using GetMealLogsUseCase
  }

  /// Loads nutrition summary for the selected date.
  Future<void> loadNutritionSummary() async {
    // TODO: Implement using GetNutritionSummaryUseCase
  }

  /// Logs a new meal.
  Future<void> logMeal(MealLog mealLog) async {
    state = state.copyWith(isLoading: true);
    // TODO: Implement using LogMealUseCase
  }

  /// Deletes a meal log.
  Future<void> deleteMealLog(String mealLogId) async {
    // TODO: Implement delete
  }
}

/// Provider for meal logging state.
final mealLoggingProvider =
    StateNotifierProvider<MealLoggingNotifier, MealLoggingState>((ref) {
  return MealLoggingNotifier();
});
