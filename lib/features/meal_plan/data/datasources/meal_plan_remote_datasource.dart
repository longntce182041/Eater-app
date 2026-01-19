import 'package:dio/dio.dart';
import '../models/meal_plan_model.dart';

abstract class MealPlanRemoteDataSource {
  Future<MealPlanModel> getDailyMealPlan(String userId, DateTime date);
  Future<MealPlanModel> getWeeklyMealPlan(String userId, DateTime startDate);
  Future<MealPlanModel> generateMealPlan(String userId, String planType, Map<String, dynamic> preferences);
  Future<List<MealPlanModel>> getMealPlanHistory(String userId);
}

class MealPlanRemoteDataSourceImpl implements MealPlanRemoteDataSource {
  final Dio dio;

  MealPlanRemoteDataSourceImpl(this.dio);

  @override
  Future<MealPlanModel> getDailyMealPlan(String userId, DateTime date) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  @override
  Future<MealPlanModel> getWeeklyMealPlan(String userId, DateTime startDate) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  @override
  Future<MealPlanModel> generateMealPlan(String userId, String planType, Map<String, dynamic> preferences) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  @override
  Future<List<MealPlanModel>> getMealPlanHistory(String userId) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }
}
