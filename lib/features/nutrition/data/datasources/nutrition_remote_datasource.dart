import 'package:dio/dio.dart';
import '../models/nutrition_tracking_model.dart';

abstract class NutritionRemoteDataSource {
  Future<NutritionTrackingModel> getTodayNutrition(String userId);
  Future<NutritionTrackingModel> getNutritionByDate(String userId, DateTime date);
  Future<List<NutritionTrackingModel>> getNutritionHistory(String userId, DateTime startDate, DateTime endDate);
  Future<void> updateWaterIntake(String userId, int waterIntake);
}

class NutritionRemoteDataSourceImpl implements NutritionRemoteDataSource {
  final Dio dio;

  NutritionRemoteDataSourceImpl(this.dio);

  @override
  Future<NutritionTrackingModel> getTodayNutrition(String userId) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  @override
  Future<NutritionTrackingModel> getNutritionByDate(String userId, DateTime date) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  @override
  Future<List<NutritionTrackingModel>> getNutritionHistory(String userId, DateTime startDate, DateTime endDate) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  @override
  Future<void> updateWaterIntake(String userId, int waterIntake) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }
}
