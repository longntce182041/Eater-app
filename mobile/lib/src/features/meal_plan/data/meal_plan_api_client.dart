import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/dio_provider.dart';
import '../domain/meal_plan_models.dart';

final mealPlanApiClientProvider = Provider<MealPlanApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  return MealPlanApiClient(dio);
});

class MealPlanApiClient {
  final Dio _dio;

  MealPlanApiClient(this._dio);

  Future<MealPlanGenerationResult> generateMealPlan({
    required int days,
    bool useML = false,
  }) async {
    final res = await _dio.post(
      '/api/ai/meal-plan/generate',
      data: {'days': days, 'useML': useML},
    );

    final data = res.data as Map<String, dynamic>;
    if (data['success'] != true) {
      debugPrint('generateMealPlan error: ${data['message']}');
      throw Exception(data['message'] ?? 'Failed to generate meal plan');
    }

    final payload = (data['data'] as Map<String, dynamic>?) ?? {};
    return MealPlanGenerationResult.fromJson(payload);
  }

  Future<MealPlanGenerationResult?> fetchLatestMealPlan() async {
    final res = await _dio.get('/api/ai/meal-plans/latest');

    final data = res.data as Map<String, dynamic>;
    if (data['success'] != true) {
      debugPrint('fetchLatestMealPlan error: ${data['message']}');
      throw Exception(data['message'] ?? 'Failed to fetch meal plan');
    }

    final payload = data['data'] as Map<String, dynamic>?;
    if (payload == null) return null;
    return MealPlanGenerationResult.fromJson(payload);
  }
}
