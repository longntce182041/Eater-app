import 'package:dio/dio.dart';
import '../models/meal_log_model.dart';

abstract class MealLogRemoteDataSource {
  Future<MealLogModel> logMeal(MealLogModel mealLog);
  Future<List<MealLogModel>> getMealLogs(String userId, DateTime date);
  Future<List<MealLogModel>> getMealLogsByDateRange(String userId, DateTime startDate, DateTime endDate);
  Future<void> deleteMealLog(String id);
  Future<MealLogModel> updateMealLog(MealLogModel mealLog);
}

class MealLogRemoteDataSourceImpl implements MealLogRemoteDataSource {
  final Dio dio;

  MealLogRemoteDataSourceImpl(this.dio);

  @override
  Future<MealLogModel> logMeal(MealLogModel mealLog) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  @override
  Future<List<MealLogModel>> getMealLogs(String userId, DateTime date) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  @override
  Future<List<MealLogModel>> getMealLogsByDateRange(String userId, DateTime startDate, DateTime endDate) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  @override
  Future<void> deleteMealLog(String id) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  @override
  Future<MealLogModel> updateMealLog(MealLogModel mealLog) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }
}
