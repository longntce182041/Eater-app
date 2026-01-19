import '../models/meal_log_model.dart';
import '../models/nutrition_summary_model.dart';

/// Local data source for caching meal logging data.
abstract class MealLoggingLocalDataSource {
  /// Caches meal logs for a date.
  Future<void> cacheMealLogs(DateTime date, List<MealLogModel> mealLogs);

  /// Gets cached meal logs for a date.
  Future<List<MealLogModel>?> getCachedMealLogs(DateTime date);

  /// Caches a single meal log.
  Future<void> cacheMealLog(MealLogModel mealLog);

  /// Caches nutrition summary for a date.
  Future<void> cacheNutritionSummary(NutritionSummaryModel summary);

  /// Gets cached nutrition summary for a date.
  Future<NutritionSummaryModel?> getCachedNutritionSummary(DateTime date);

  /// Clears all cached meal logging data.
  Future<void> clearCache();
}
