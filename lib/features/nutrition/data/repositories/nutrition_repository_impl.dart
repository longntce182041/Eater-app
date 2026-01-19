import '../../domain/entities/nutrition_tracking.dart';
import '../../domain/repositories/nutrition_repository.dart';
import '../datasources/nutrition_remote_datasource.dart';

class NutritionRepositoryImpl implements NutritionRepository {
  final NutritionRemoteDataSource remoteDataSource;

  NutritionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<NutritionTracking> getTodayNutrition(String userId) async {
    // TODO: Implement get today nutrition logic
    throw UnimplementedError();
  }

  @override
  Future<NutritionTracking> getNutritionByDate(String userId, DateTime date) async {
    // TODO: Implement get nutrition by date logic
    throw UnimplementedError();
  }

  @override
  Future<List<NutritionTracking>> getNutritionHistory(String userId, DateTime startDate, DateTime endDate) async {
    // TODO: Implement get nutrition history logic
    throw UnimplementedError();
  }

  @override
  Future<void> updateWaterIntake(String userId, int waterIntake) async {
    // TODO: Implement update water intake logic
    throw UnimplementedError();
  }
}
