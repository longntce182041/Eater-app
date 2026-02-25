import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/dio_provider.dart';
import '../domain/recipe_models.dart';

final recipeApiClientProvider = Provider<RecipeApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  return RecipeApiClient(dio);
});

class RecipeApiClient {
  final Dio _dio;

  RecipeApiClient(this._dio);

  /// Get all recipes with pagination
  /// Default: status=published, page=1, limit=10
  Future<RecipeListResponse> getAllRecipes({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      debugPrint('Fetching recipes - page: $page, limit: $limit');

      final queryParams = {
        'page': page,
        'limit': limit,
        if (status != null) 'status': status,
      };

      final response = await _dio.get(
        '/api/recipes',
        queryParameters: queryParams,
      );

      debugPrint(
        'Recipes fetched successfully: ${response.data['data']['total']} total',
      );
      return RecipeListResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('Error fetching recipes: ${e.response?.data}');
      rethrow;
    }
  }

  /// Search recipes by keyword
  /// Searches in both name and description
  Future<RecipeListResponse> searchRecipes({
    required String keyword,
    int page = 1,
    int limit = 10,
    String? status,
    int? maxCookingTime,
  }) async {
    try {
      debugPrint('Searching recipes - keyword: "$keyword", page: $page');

      final queryParams = {
        'keyword': keyword,
        'page': page,
        'limit': limit,
        if (status != null) 'status': status,
        if (maxCookingTime != null) 'maxCookingTime': maxCookingTime,
      };

      final response = await _dio.get(
        '/api/recipes',
        queryParameters: queryParams,
      );

      debugPrint(
        'Search results: ${response.data['data']['total']} recipes found',
      );
      return RecipeListResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('Error searching recipes: ${e.response?.data}');
      rethrow;
    }
  }

  /// Get quick meals (recipes with cooking time <= maxMinutes)
  Future<RecipeListResponse> getQuickMeals({
    required int maxMinutes,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      debugPrint('Fetching quick meals - max time: $maxMinutes min');

      final queryParams = {
        'maxCookingTime': maxMinutes,
        'page': page,
        'limit': limit,
      };

      final response = await _dio.get(
        '/api/recipes',
        queryParameters: queryParams,
      );

      return RecipeListResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('Error fetching quick meals: ${e.response?.data}');
      rethrow;
    }
  }

  /// Get recipe detail by ID
  Future<Recipe> getRecipeById(String id) async {
    try {
      debugPrint('Fetching recipe detail - id: $id');

      final response = await _dio.get('/api/recipes/$id');

      final recipeData = response.data['data'] as Map<String, dynamic>;
      return Recipe.fromJson(recipeData);
    } on DioException catch (e) {
      debugPrint('Error fetching recipe detail: ${e.response?.data}');
      rethrow;
    }
  }

  /// Get nutrition values for a recipe by ID
  Future<RecipeNutrition> getRecipeNutrition(String recipeId) async {
    try {
      debugPrint('Fetching nutrition values - recipe id: $recipeId');

      final response = await _dio.get('/api/recipes/$recipeId/nutrition');

      final nutritionData = response.data['data'] as Map<String, dynamic>;
      return RecipeNutrition.fromJson(nutritionData);
    } on DioException catch (e) {
      debugPrint('Error fetching nutrition: ${e.response?.data}');
      rethrow;
    }
  }
}
