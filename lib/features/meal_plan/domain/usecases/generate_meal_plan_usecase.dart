import '../entities/meal_plan.dart';
import '../repositories/meal_plan_repository.dart';

class GenerateMealPlanUseCase {
  final MealPlanRepository repository;

  GenerateMealPlanUseCase(this.repository);

  Future<MealPlan> call(String userId, String planType, Map<String, dynamic> preferences) {
    return repository.generateMealPlan(userId, planType, preferences);
  }
}
