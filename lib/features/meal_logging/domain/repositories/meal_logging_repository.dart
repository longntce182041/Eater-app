import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/meal_log.dart';
import '../entities/nutrition_summary.dart';

/// Repository interface for meal logging operations.
abstract class MealLoggingRepository {
  /// Logs a meal.
  Future<Either<Failure, MealLog>> logMeal(MealLog mealLog);

  /// Gets meal logs for a specific date.
  Future<Either<Failure, List<MealLog>>> getMealLogs(DateTime date);

  /// Gets meal logs for a date range.
  Future<Either<Failure, List<MealLog>>> getMealLogsRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Updates a meal log.
  Future<Either<Failure, MealLog>> updateMealLog(MealLog mealLog);

  /// Deletes a meal log.
  Future<Either<Failure, void>> deleteMealLog(String mealLogId);

  /// Gets nutrition summary for a specific date.
  Future<Either<Failure, NutritionSummary>> getNutritionSummary(DateTime date);

  /// Gets nutrition summary for a date range.
  Future<Either<Failure, List<NutritionSummary>>> getNutritionSummaryRange({
    required DateTime startDate,
    required DateTime endDate,
  });
}
