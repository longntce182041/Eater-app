import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/dietary_preferences.dart';
import '../../domain/entities/health_goal.dart';

/// State for dietary preferences.
class DietaryPreferencesState {
  final bool isLoading;
  final DietaryPreferences? preferences;
  final List<HealthGoal> healthGoals;
  final String? errorMessage;

  const DietaryPreferencesState({
    this.isLoading = false,
    this.preferences,
    this.healthGoals = const [],
    this.errorMessage,
  });

  DietaryPreferencesState copyWith({
    bool? isLoading,
    DietaryPreferences? preferences,
    List<HealthGoal>? healthGoals,
    String? errorMessage,
  }) {
    return DietaryPreferencesState(
      isLoading: isLoading ?? this.isLoading,
      preferences: preferences ?? this.preferences,
      healthGoals: healthGoals ?? this.healthGoals,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Dietary preferences notifier.
class DietaryPreferencesNotifier
    extends StateNotifier<DietaryPreferencesState> {
  DietaryPreferencesNotifier() : super(const DietaryPreferencesState());

  /// Loads dietary preferences.
  Future<void> loadPreferences() async {
    state = state.copyWith(isLoading: true);
    // TODO: Implement using GetDietaryPreferencesUseCase
  }

  /// Updates dietary preferences.
  Future<void> updatePreferences(DietaryPreferences preferences) async {
    state = state.copyWith(isLoading: true);
    // TODO: Implement using UpdateDietaryPreferencesUseCase
  }

  /// Loads health goals.
  Future<void> loadHealthGoals() async {
    // TODO: Implement
  }

  /// Adds a health goal.
  Future<void> addHealthGoal(HealthGoal goal) async {
    // TODO: Implement
  }
}

/// Provider for dietary preferences state.
final dietaryPreferencesProvider =
    StateNotifierProvider<DietaryPreferencesNotifier, DietaryPreferencesState>(
  (ref) => DietaryPreferencesNotifier(),
);
