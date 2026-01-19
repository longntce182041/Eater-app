import '../models/meal_plan_model.dart';

/// Local data source for caching meal plan data.
abstract class MealPlanLocalDataSource {
  /// Caches a meal plan.
  Future<void> cacheMealPlan(MealPlanModel mealPlan);

  /// Gets a cached meal plan by date.
  Future<MealPlanModel?> getCachedMealPlan(DateTime date);

  /// Caches weekly meal plans.
  Future<void> cacheWeeklyMealPlans(List<MealPlanModel> mealPlans);

  /// Gets cached weekly meal plans.
  Future<List<MealPlanModel>?> getCachedWeeklyMealPlans(DateTime startDate);

  /// Clears all cached meal plans.
  Future<void> clearCache();
}
