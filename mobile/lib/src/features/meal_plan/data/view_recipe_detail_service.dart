import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ViewRecipeDetailService {
  final Dio dio;

  ViewRecipeDetailService({required this.dio});

  static const String baseUrl = '/api/view-recipe-details';

  /// Get full recipe details (ingredients, steps, nutrition, micronutrients)
  /// Dedicated service for meal plan recipe viewing
  Future<Map<String, dynamic>> getFullRecipeDetails(String recipeId) async {
    try {
      debugPrint(
          '[ViewRecipeDetailService] Fetching recipe details for ID: $recipeId');

      final response = await dio.get(
        '$baseUrl/$recipeId/full-details',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        debugPrint(
            '[ViewRecipeDetailService] Recipe details fetched successfully');
        debugPrint(
            '[ViewRecipeDetailService] Recipe: ${data['name']}, Ingredients: ${(data['ingredients'] as List?)?.length ?? 0}');

        return data as Map<String, dynamic>;
      } else {
        throw Exception(
            'Failed to fetch recipe details: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('[ViewRecipeDetailService] DioException: ${e.message}');
      throw Exception('Error fetching recipe details: ${e.message}');
    } catch (e) {
      debugPrint('[ViewRecipeDetailService] Exception: $e');
      throw Exception('Unexpected error fetching recipe details: $e');
    }
  }

  /// Get recipe basic info only
  Future<Map<String, dynamic>> getRecipeBasicInfo(String recipeId) async {
    try {
      final response = await dio.get('$baseUrl/$recipeId');

      if (response.statusCode == 200) {
        return response.data['data'] ?? response.data;
      } else {
        throw Exception('Failed to fetch recipe: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Error fetching recipe: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error fetching recipe: $e');
    }
  }
}
