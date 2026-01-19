import '../entities/meal_plan.dart';

abstract class MealPlanRepository {
  Future<MealPlan> getDailyMealPlan(String userId, DateTime date);
  Future<MealPlan> getWeeklyMealPlan(String userId, DateTime startDate);
  Future<MealPlan> generateMealPlan(String userId, String planType, Map<String, dynamic> preferences);
  Future<List<MealPlan>> getMealPlanHistory(String userId);
}
