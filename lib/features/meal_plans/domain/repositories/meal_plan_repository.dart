import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/meal_plan.dart';

/// Repository interface for meal plan operations.
abstract class MealPlanRepository {
  /// Gets the daily meal plan for a specific date.
  Future<Either<Failure, MealPlan>> getDailyMealPlan(DateTime date);

  /// Gets the weekly meal plan starting from a specific date.
  Future<Either<Failure, List<MealPlan>>> getWeeklyMealPlan(DateTime startDate);

  /// Generates an AI-based meal plan.
  Future<Either<Failure, MealPlan>> generateMealPlan({
    required DateTime date,
    required String planType,
    int? targetCalories,
  });

  /// Creates a custom meal plan.
  Future<Either<Failure, MealPlan>> createMealPlan(MealPlan mealPlan);

  /// Updates a meal plan.
  Future<Either<Failure, MealPlan>> updateMealPlan(MealPlan mealPlan);

  /// Deletes a meal plan.
  Future<Either<Failure, void>> deleteMealPlan(String mealPlanId);

  /// Gets meal plan history.
  Future<Either<Failure, List<MealPlan>>> getMealPlanHistory({
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  });
}
