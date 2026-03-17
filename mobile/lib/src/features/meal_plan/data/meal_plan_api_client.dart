import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/app_config_provider.dart';
import '../../../shared/providers/dio_provider.dart';
import '../domain/meal_plan_models.dart';

final mealPlanApiClientProvider = Provider<MealPlanApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  final config = ref.watch(appConfigProvider);
  return MealPlanApiClient(dio, config.apiBaseUrl);
});

class MealPlanApiClient {
  final Dio _dio;
  final String baseUrl;

  MealPlanApiClient(this._dio, this.baseUrl);

  Future<MealPlanGenerationResult> generateMealPlan({
    required int days,
    bool useML = false,
  }) async {
    final url = '$baseUrl/api/ai/meal-plan/generate';
    final res = await _dio.post(url, data: {'days': days, 'useML': useML});

    final data = res.data as Map<String, dynamic>;
    if (data['success'] != true) {
      debugPrint('generateMealPlan error: ${data['message']}');
      throw Exception(data['message'] ?? 'Failed to generate meal plan');
    }

    final payload = (data['data'] as Map<String, dynamic>?) ?? {};
    return MealPlanGenerationResult.fromJson(payload);
  }

  Future<MealPlanGenerationResult?> fetchLatestMealPlan() async {
    final url = '$baseUrl/api/ai/meal-plans/latest';
    final res = await _dio.get(url);

    final data = res.data as Map<String, dynamic>;
    if (data['success'] != true) {
      debugPrint('fetchLatestMealPlan error: ${data['message']}');
      throw Exception(data['message'] ?? 'Failed to fetch meal plan');
    }

    final payload = data['data'] as Map<String, dynamic>?;
    if (payload == null) return null;
    return MealPlanGenerationResult.fromJson(payload);
  }

  Future<void> deleteLatestMealPlan() async {
    final url = '$baseUrl/api/ai/meal-plans/latest';
    final res = await _dio.delete(url);

    final data = res.data as Map<String, dynamic>;
    if (data['success'] != true) {
      debugPrint('deleteLatestMealPlan error: ${data['message']}');
      throw Exception(data['message'] ?? 'Failed to delete meal plan');
    }
  }

  Future<void> deleteMealPlanById(String mealPlanId) async {
    final url = '$baseUrl/api/ai/meal-plans/$mealPlanId';
    final res = await _dio.delete(url);

    final data = res.data as Map<String, dynamic>;
    if (data['success'] != true) {
      debugPrint('deleteMealPlanById error: ${data['message']}');
      throw Exception(data['message'] ?? 'Failed to delete meal plan');
    }
  }

  Future<void> deleteAllMealPlans() async {
    final url = '$baseUrl/api/ai/meal-plans';
    final res = await _dio.delete(url);

    final data = res.data as Map<String, dynamic>;
    if (data['success'] != true) {
      debugPrint('deleteAllMealPlans error: ${data['message']}');
      throw Exception(data['message'] ?? 'Failed to delete meal plans');
    }
  }

  /// Get replacement suggestions for a meal
  Future<List<Map<String, dynamic>>> getReplacementSuggestions(
    String planId,
    String itemId,
  ) async {
    try {
      final url = '$baseUrl/api/meal-plans/$planId/items/$itemId/suggestions';
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          final suggestionsData = data['data'] as Map<String, dynamic>;
          final suggestions =
              (suggestionsData['suggestions'] as List?)
                  ?.map((e) => e as Map<String, dynamic>)
                  .toList() ??
              [];
          return suggestions;
        } else {
          throw Exception(data['message'] ?? 'Failed to get suggestions');
        }
      } else {
        throw Exception('Failed to get replacement suggestions');
      }
    } catch (e) {
      debugPrint('Error getting replacement suggestions: $e');
      throw Exception('Failed to get replacement suggestions: $e');
    }
  }

  /// Replace a meal in meal plan
  Future<MealPlanItemModel> replaceMeal(
    String planId,
    String itemId,
    String newRecipeId,
    String? reason,
  ) async {
    try {
      final url = '$baseUrl/api/meal-plans/$planId/items/$itemId/replace';
      final response = await _dio.patch(
        url,
        data: {'newRecipeId': newRecipeId, 'reason': reason},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          final itemData = data['data'] as Map<String, dynamic>;
          return MealPlanItemModel.fromJson(itemData);
        } else {
          throw Exception(data['message'] ?? 'Failed to replace meal');
        }
      } else {
        throw Exception('Failed to replace meal');
      }
    } catch (e) {
      debugPrint('Error replacing meal: $e');
      throw Exception('Failed to replace meal: $e');
    }
  }

  /// Rate a meal (1-5 stars)
  Future<MealPlanItemModel> rateMeal(
    String planId,
    String itemId,
    int rating,
  ) async {
    try {
      final url = '$baseUrl/api/meal-plans/$planId/items/$itemId/rate';
      final response = await _dio.post(url, data: {'rating': rating});

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          final itemData = data['data'] as Map<String, dynamic>;
          return MealPlanItemModel.fromJson(itemData);
        } else {
          throw Exception(data['message'] ?? 'Failed to rate meal');
        }
      } else {
        throw Exception('Failed to rate meal');
      }
    } catch (e) {
      debugPrint('Error rating meal: $e');
      throw Exception('Failed to rate meal: $e');
    }
  }

  /// Get optimization suggestions for a meal plan
  Future<Map<String, dynamic>> getOptimizationSuggestions(String planId) async {
    try {
      final url = '$baseUrl/api/meal-plans/$planId/optimization-suggestions';
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>;
        } else {
          throw Exception(
            data['message'] ?? 'Failed to get optimization suggestions',
          );
        }
      } else {
        throw Exception('Failed to get optimization suggestions');
      }
    } catch (e) {
      debugPrint('Error getting optimization suggestions: $e');
      throw Exception('Failed to get optimization suggestions: $e');
    }
  }

  /// Optimize entire meal plan
  Future<Map<String, dynamic>> optimizeMealPlan(String planId) async {
    try {
      final url = '$baseUrl/api/meal-plans/$planId/optimize';
      final response = await _dio.post(url);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>;
        } else {
          throw Exception(data['message'] ?? 'Failed to optimize meal plan');
        }
      } else {
        throw Exception('Failed to optimize meal plan');
      }
    } catch (e) {
      debugPrint('Error optimizing meal plan: $e');
      throw Exception('Failed to optimize meal plan: $e');
    }
  }

  /// Generate meal plan preview (no database save yet)
  Future<Map<String, dynamic>> generateMealPlanPreview({
    required String userId,
    required int age,
    required String gender,
    required double heightCm,
    required double weightKg,
    required double goalWeightKg,
    required String healthGoals,
    required String activityLevel,
    required List<String> dietTypes,
    required List<String> allergies,
    required List<String> dislikedIngredients,
    required int days,
  }) async {
    final url = '$baseUrl/api/ai/meal-plan/preview';
    final res = await _dio.post(
      url,
      data: {
        'userId': userId,
        'age': age,
        'gender': gender,
        'height_cm': heightCm,
        'weight_kg': weightKg,
        'goal_weight_kg': goalWeightKg,
        'health_goals': healthGoals,
        'activity_level': activityLevel,
        'dietTypes': dietTypes,
        'allergies': allergies,
        'disliked_ingredients': dislikedIngredients,
        'days': days,
      },
    );

    final data = res.data as Map<String, dynamic>;
    if (data['success'] != true) {
      debugPrint('generateMealPlanPreview error: ${data['message']}');
      throw Exception(
        data['message'] ?? 'Failed to generate meal plan preview',
      );
    }

    return data['data'] as Map<String, dynamic>;
  }

  /// Save modified meals from preview
  Future<MealPlanGenerationResult> saveMealPlanFromPreview({
    required String userId,
    required Map<String, dynamic> originalAIMealPlan,
    required Map<String, dynamic> mealPlanOptions,
    required Map<String, dynamic> modifiedMeals,
  }) async {
    final url = '$baseUrl/api/ai/meal-plan/save-preview';
    final res = await _dio.post(
      url,
      data: {
        'userId': userId,
        'originalAIMealPlan': originalAIMealPlan,
        'mealPlanOptions': mealPlanOptions,
        'modifiedMeals': modifiedMeals,
      },
    );

    final data = res.data as Map<String, dynamic>;
    if (data['success'] != true) {
      debugPrint('saveMealPlanFromPreview error: ${data['message']}');
      throw Exception(data['message'] ?? 'Failed to save meal plan');
    }

    return MealPlanGenerationResult.fromJson(
      data['data'] as Map<String, dynamic>,
    );
  }
}
