import 'package:dio/dio.dart';

class RecipeDetailService {
  final Dio dio;

  RecipeDetailService({required this.dio});

  static const String baseUrl = '/api/recipes';

  /// Get full recipe details (ingredients, steps, nutrition, micronutrients)
  /// Returns the recipe data from backend
  Future<Map<String, dynamic>> getRecipeFullDetails(String recipeId) async {
    try {
      print('[RecipeDetailService] Fetching recipe details for ID: $recipeId');
      
      final response = await dio.get(
        '$baseUrl/$recipeId/full-details',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        print('[RecipeDetailService] Recipe details fetched successfully');
        print('[RecipeDetailService] Recipe: ${data['name']}, Ingredients: ${(data['ingredients'] as List?)?.length ?? 0}');
        
        return data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch recipe details: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('[RecipeDetailService] DioException: ${e.message}');
      throw Exception('Error fetching recipe details: ${e.message}');
    } catch (e) {
      print('[RecipeDetailService] Exception: $e');
      throw Exception('Unexpected error fetching recipe details: $e');
    }
  }

  /// Get recipe by ID (basic info only)
  Future<Map<String, dynamic>> getRecipeById(String recipeId) async {
    try {
      final response = await dio.get('$baseUrl/$recipeId');

      if (response.statusCode == 200) {
        return response.data['data'] ?? response.data;
      } else {
        throw Exception('Failed to fetch recipe: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Error fetching recipe: ${e.message}');
    }
  }

  /// Get recipe nutrition
  Future<Map<String, dynamic>> getRecipeNutrition(String recipeId) async {
    try {
      final response = await dio.get('$baseUrl/$recipeId/nutrition');

      if (response.statusCode == 200) {
        return response.data['data'] ?? response.data;
      } else {
        throw Exception('Failed to fetch nutrition: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Error fetching nutrition: ${e.message}');
    }
  }
}
