import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/meal_log.dart';

class MealLogState {
  final bool isLoading;
  final List<MealLog> mealLogs;
  final String? error;

  MealLogState({
    this.isLoading = false,
    this.mealLogs = const [],
    this.error,
  });

  MealLogState copyWith({
    bool? isLoading,
    List<MealLog>? mealLogs,
    String? error,
  }) {
    return MealLogState(
      isLoading: isLoading ?? this.isLoading,
      mealLogs: mealLogs ?? this.mealLogs,
      error: error ?? this.error,
    );
  }
}

class MealLogNotifier extends StateNotifier<MealLogState> {
  MealLogNotifier() : super(MealLogState());

  Future<void> logMeal(MealLog mealLog) async {
    // TODO: Implement log meal
  }

  Future<void> loadMealLogs(String userId, DateTime date) async {
    // TODO: Implement load meal logs
  }

  Future<void> deleteMealLog(String id) async {
    // TODO: Implement delete meal log
  }
}

final mealLogProvider = StateNotifierProvider<MealLogNotifier, MealLogState>((ref) {
  return MealLogNotifier();
});
