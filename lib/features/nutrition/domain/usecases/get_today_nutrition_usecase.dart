import '../entities/nutrition_tracking.dart';
import '../repositories/nutrition_repository.dart';

class GetTodayNutritionUseCase {
  final NutritionRepository repository;

  GetTodayNutritionUseCase(this.repository);

  Future<NutritionTracking> call(String userId) {
    return repository.getTodayNutrition(userId);
  }
}
