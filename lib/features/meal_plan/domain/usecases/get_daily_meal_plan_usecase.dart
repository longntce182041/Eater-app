import '../entities/meal_plan.dart';
import '../repositories/meal_plan_repository.dart';

class GetDailyMealPlanUseCase {
  final MealPlanRepository repository;

  GetDailyMealPlanUseCase(this.repository);

  Future<MealPlan> call(String userId, DateTime date) {
    return repository.getDailyMealPlan(userId, date);
  }
}
