import '../entities/nutrition_tracking.dart';
import '../repositories/nutrition_repository.dart';

class GetNutritionHistoryUseCase {
  final NutritionRepository repository;

  GetNutritionHistoryUseCase(this.repository);

  Future<List<NutritionTracking>> call(String userId, DateTime startDate, DateTime endDate) {
    return repository.getNutritionHistory(userId, startDate, endDate);
  }
}
