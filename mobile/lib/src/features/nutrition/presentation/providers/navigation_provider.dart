import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

/// Provider for target meal date when navigating to meal logging from meal plan
/// Used to auto-select the date of newly logged meal
final targetMealDateProvider =
    StateNotifierProvider<TargetMealDateNotifier, DateTime?>((ref) {
  return TargetMealDateNotifier();
});

class TargetMealDateNotifier extends StateNotifier<DateTime?> {
  TargetMealDateNotifier() : super(null);

  void setTargetDate(DateTime date) {
    state = date;
    debugPrint(
        '[navigation_provider] Target meal date set to: ${date.toString().split(' ')[0]}');
  }

  void clearTargetDate() {
    state = null;
  }
}

/// Provider for target navigation tab index in MainNavigationPage
/// Used to auto-navigate to Meal Logging tab when meal is logged
final targetTabIndexProvider =
    StateNotifierProvider<TargetTabIndexNotifier, int?>((ref) {
  return TargetTabIndexNotifier();
});

class TargetTabIndexNotifier extends StateNotifier<int?> {
  TargetTabIndexNotifier() : super(null);

  void setTargetTab(int index) {
    state = index;
    debugPrint('[navigation_provider] Target tab index set to: $index');
  }

  void clearTargetTab() {
    state = null;
  }
}
