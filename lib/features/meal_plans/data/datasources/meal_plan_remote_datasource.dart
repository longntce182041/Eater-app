import '../models/meal_plan_model.dart';

/// Remote data source for meal plan operations.
abstract class MealPlanRemoteDataSource {
  /// Gets the daily meal plan for a specific date.
  Future<MealPlanModel> getDailyMealPlan(DateTime date);

  /// Gets the weekly meal plan starting from a specific date.
  Future<List<MealPlanModel>> getWeeklyMealPlan(DateTime startDate);

  /// Generates an AI-based meal plan.
  Future<MealPlanModel> generateMealPlan({
    required DateTime date,
    required String planType,
    int? targetCalories,
  });

  /// Creates a custom meal plan.
  Future<MealPlanModel> createMealPlan(MealPlanModel mealPlan);

  /// Updates a meal plan.
  Future<MealPlanModel> updateMealPlan(MealPlanModel mealPlan);

  /// Deletes a meal plan.
  Future<void> deleteMealPlan(String mealPlanId);

  /// Gets meal plan history.
  Future<List<MealPlanModel>> getMealPlanHistory({
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  });
}
