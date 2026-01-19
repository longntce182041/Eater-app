import '../entities/meal_log.dart';

abstract class MealLogRepository {
  Future<MealLog> logMeal(MealLog mealLog);
  Future<List<MealLog>> getMealLogs(String userId, DateTime date);
  Future<List<MealLog>> getMealLogsByDateRange(String userId, DateTime startDate, DateTime endDate);
  Future<void> deleteMealLog(String id);
  Future<MealLog> updateMealLog(MealLog mealLog);
}
