import '../models/meal_log_model.dart';
import '../models/nutrition_summary_model.dart';

/// Remote data source for meal logging operations.
abstract class MealLoggingRemoteDataSource {
  /// Logs a meal.
  Future<MealLogModel> logMeal(MealLogModel mealLog);

  /// Gets meal logs for a specific date.
  Future<List<MealLogModel>> getMealLogs(DateTime date);

  /// Gets meal logs for a date range.
  Future<List<MealLogModel>> getMealLogsRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Updates a meal log.
  Future<MealLogModel> updateMealLog(MealLogModel mealLog);

  /// Deletes a meal log.
  Future<void> deleteMealLog(String mealLogId);

  /// Gets nutrition summary for a specific date.
  Future<NutritionSummaryModel> getNutritionSummary(DateTime date);

  /// Gets nutrition summary for a date range.
  Future<List<NutritionSummaryModel>> getNutritionSummaryRange({
    required DateTime startDate,
    required DateTime endDate,
  });
}
