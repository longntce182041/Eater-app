import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/meal_log.dart';
import '../../data/providers/meal_log_service_provider.dart';

// Meal logs provider - stores all meal logs for the current user
final mealLogsProvider =
    StateNotifierProvider<MealLogsNotifier, List<MealLog>>((ref) {
  return MealLogsNotifier();
});

class MealLogsNotifier extends StateNotifier<List<MealLog>> {
  MealLogsNotifier() : super([]);

  // Add a new meal log to local state only
  void addMealLog(MealLog mealLog) {
    state = [...state, mealLog];
  }

  // Set all meal logs (for initialization from backend)
  void setMealLogs(List<MealLog> mealLogs) {
    state = mealLogs;
  }

  // Update an existing meal log
  void updateMealLog(MealLog mealLog) {
    state = [
      for (final log in state)
        if (log.id == mealLog.id) mealLog else log,
    ];
  }

  // Delete a meal log from local state only
  void deleteMealLog(String mealLogId) {
    state = state.where((log) => log.id != mealLogId).toList();
  }

  // Get meal logs for a specific date
  List<MealLog> getMealLogsForDate(DateTime date) {
    return state.where((log) {
      return log.loggedAt.year == date.year &&
          log.loggedAt.month == date.month &&
          log.loggedAt.day == date.day;
    }).toList();
  }

  // Get meal logs for today
  List<MealLog> getTodayMealLogs() {
    return getMealLogsForDate(DateTime.now());
  }

  // Calculate daily totals
  Map<String, double> getDailyTotals(DateTime date) {
    final logs = getMealLogsForDate(date);
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFats = 0;

    for (final log in logs) {
      totalCalories += log.calories;
      totalProtein += log.protein;
      totalCarbs += log.carbs;
      totalFats += log.fats;
    }

    return {
      'calories': totalCalories,
      'protein': totalProtein,
      'carbs': totalCarbs,
      'fats': totalFats,
    };
  }

  // Get meal logs by type (breakfast, lunch, dinner, snack)
  List<MealLog> getMealLogsByType(String mealType, DateTime date) {
    return getMealLogsForDate(date)
        .where((log) => log.mealType == mealType)
        .toList();
  }
}

// Provider for today's totals
final todayTotalsProvider = Provider<Map<String, double>>((ref) {
  final mealLogs = ref.watch(mealLogsProvider);
  double totalCalories = 0;
  double totalProtein = 0;
  double totalCarbs = 0;
  double totalFats = 0;

  for (final log in mealLogs) {
    if (log.loggedAt.year == DateTime.now().year &&
        log.loggedAt.month == DateTime.now().month &&
        log.loggedAt.day == DateTime.now().day) {
      totalCalories += log.calories;
      totalProtein += log.protein;
      totalCarbs += log.carbs;
      totalFats += log.fats;
    }
  }

  return {
    'calories': totalCalories,
    'protein': totalProtein,
    'carbs': totalCarbs,
    'fats': totalFats,
  };
});

// Provider for today's meal logs
final todayMealLogsProvider = Provider<List<MealLog>>((ref) {
  final mealLogs = ref.watch(mealLogsProvider);
  final now = DateTime.now();
  return mealLogs.where((log) {
    return log.loggedAt.year == now.year &&
        log.loggedAt.month == now.month &&
        log.loggedAt.day == now.day;
  }).toList();
});

// FutureProvider to fetch all meal logs from backend
final allMealLogsFromBackendProvider =
    FutureProvider<List<MealLog>>((ref) async {
  final mealLogService = ref.watch(mealLogServiceProvider);
  try {
    return await mealLogService.getAllMealLogs();
  } catch (e) {
    debugPrint('Error fetching meal logs from backend: $e');
    return [];
  }
});

// Provider to initialize meal logs from backend on app startup
// Only fetches once per app lifecycle using cache
final initializeMealLogsProvider = FutureProvider<void>((ref) async {
  // Use allMealLogsFromBackendProvider which has built-in caching
  final mealLogs = await ref.watch(allMealLogsFromBackendProvider.future);
  // Load fetched meals into local state (replaces any existing state)
  ref.read(mealLogsProvider.notifier).setMealLogs(mealLogs);
});
