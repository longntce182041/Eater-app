import '../entities/meal_log.dart';
import '../repositories/meal_log_repository.dart';

class GetMealLogsUseCase {
  final MealLogRepository repository;

  GetMealLogsUseCase(this.repository);

  Future<List<MealLog>> call(String userId, DateTime date) {
    return repository.getMealLogs(userId, date);
  }
}
