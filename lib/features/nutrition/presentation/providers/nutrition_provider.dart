import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/nutrition_tracking.dart';

class NutritionState {
  final bool isLoading;
  final NutritionTracking? todayNutrition;
  final List<NutritionTracking> history;
  final String? error;

  NutritionState({
    this.isLoading = false,
    this.todayNutrition,
    this.history = const [],
    this.error,
  });

  NutritionState copyWith({
    bool? isLoading,
    NutritionTracking? todayNutrition,
    List<NutritionTracking>? history,
    String? error,
  }) {
    return NutritionState(
      isLoading: isLoading ?? this.isLoading,
      todayNutrition: todayNutrition ?? this.todayNutrition,
      history: history ?? this.history,
      error: error ?? this.error,
    );
  }
}

class NutritionNotifier extends StateNotifier<NutritionState> {
  NutritionNotifier() : super(NutritionState());

  Future<void> loadTodayNutrition(String userId) async {
    // TODO: Implement load today nutrition
  }

  Future<void> loadNutritionHistory(String userId, DateTime startDate, DateTime endDate) async {
    // TODO: Implement load nutrition history
  }

  Future<void> updateWaterIntake(String userId, int waterIntake) async {
    // TODO: Implement update water intake
  }
}

final nutritionProvider = StateNotifierProvider<NutritionNotifier, NutritionState>((ref) {
  return NutritionNotifier();
});
