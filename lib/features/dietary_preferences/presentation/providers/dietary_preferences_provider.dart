import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/dietary_preferences.dart';

class DietaryPreferencesState {
  final bool isLoading;
  final DietaryPreferences? preferences;
  final String? error;

  DietaryPreferencesState({
    this.isLoading = false,
    this.preferences,
    this.error,
  });

  DietaryPreferencesState copyWith({
    bool? isLoading,
    DietaryPreferences? preferences,
    String? error,
  }) {
    return DietaryPreferencesState(
      isLoading: isLoading ?? this.isLoading,
      preferences: preferences ?? this.preferences,
      error: error ?? this.error,
    );
  }
}

class DietaryPreferencesNotifier extends StateNotifier<DietaryPreferencesState> {
  DietaryPreferencesNotifier() : super(DietaryPreferencesState());

  Future<void> loadPreferences(String userId) async {
    // TODO: Implement load preferences
  }

  Future<void> updatePreferences(DietaryPreferences preferences) async {
    // TODO: Implement update preferences
  }
}

final dietaryPreferencesProvider = StateNotifierProvider<DietaryPreferencesNotifier, DietaryPreferencesState>((ref) {
  return DietaryPreferencesNotifier();
});
