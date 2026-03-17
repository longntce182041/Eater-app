import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/recipe_models.dart';
import '../../../shared/providers/app_config_provider.dart';
import '../../../shared/providers/dio_provider.dart';

/// Provider for recipe ingredients API client
final recipeIngredientsApiProvider = Provider<RecipeIngredientsApi>((ref) {
  final dio = ref.watch(dioProvider);
  final config = ref.watch(appConfigProvider);
  return RecipeIngredientsApi(dio, config.apiBaseUrl);
});

/// API client for fetching recipe ingredients
class RecipeIngredientsApi {
  final Dio _dio;
  final String baseUrl;

  RecipeIngredientsApi(this._dio, this.baseUrl);

  /// Fetch recipe detail with ingredients
  Future<List<RecipeIngredient>> getRecipeIngredients(String recipeId) async {
    try {
      final url = '$baseUrl/api/recipes/$recipeId';
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        final ingredientsJson = data['ingredients'] as List<dynamic>?;

        if (ingredientsJson == null || ingredientsJson.isEmpty) {
          return [];
        }

        return ingredientsJson
            .map(
              (json) => RecipeIngredient.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw Exception('Failed to load recipe ingredients');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Recipe not found');
      }
      throw Exception('Failed to load ingredients: ${e.message}');
    }
  }
}

/// Provider for recipe ingredients
/// Returns list of ingredients for a specific recipe
final recipeIngredientsProvider =
    FutureProvider.family<List<RecipeIngredient>, String>((
      ref,
      recipeId,
    ) async {
      final api = ref.watch(recipeIngredientsApiProvider);
      return api.getRecipeIngredients(recipeId);
    });
