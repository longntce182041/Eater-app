import '../entities/meal_log.dart';
import '../repositories/meal_log_repository.dart';

class LogMealUseCase {
  final MealLogRepository repository;

  LogMealUseCase(this.repository);

  Future<MealLog> call(MealLog mealLog) {
    return repository.logMeal(mealLog);
  }
}
