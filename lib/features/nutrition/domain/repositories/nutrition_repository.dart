import '../entities/nutrition_tracking.dart';

abstract class NutritionRepository {
  Future<NutritionTracking> getTodayNutrition(String userId);
  Future<NutritionTracking> getNutritionByDate(String userId, DateTime date);
  Future<List<NutritionTracking>> getNutritionHistory(String userId, DateTime startDate, DateTime endDate);
  Future<void> updateWaterIntake(String userId, int waterIntake);
}
