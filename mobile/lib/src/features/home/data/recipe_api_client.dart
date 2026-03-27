import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/app_config_provider.dart';
import '../../../shared/providers/dio_provider.dart';
import '../domain/recipe_models.dart';

final recipeApiClientProvider = Provider<RecipeApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  final config = ref.watch(appConfigProvider);
  return RecipeApiClient(dio, config.apiBaseUrl);
});

class RecipeApiClient {
  final Dio _dio;
  final String baseUrl;

  RecipeApiClient(this._dio, this.baseUrl);

  Future<RecipeFilterOptions> getRecipeFilterOptions({String? status}) async {
    try {
      final url = '$baseUrl/api/recipes/filter-options';
      final response = await _dio.get(
        url,
        queryParameters: {
          if (status != null && status.isNotEmpty) 'status': status,
        },
      );

      return RecipeFilterOptions.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      debugPrint('Error fetching filter options: ${e.response?.data}');
      rethrow;
    }
  }

  Map<String, dynamic> _buildFilterQueryParams({
    int? maxCookingTime,
    double? minCalories,
    double? maxCalories,
    double? minProtein,
    double? maxProtein,
    double? minFat,
    double? maxFat,
    double? minCarbohydrates,
    double? maxCarbohydrates,
    List<String>? dietTypes,
    List<String>? ingredients,
  }) {
    return {
      if (maxCookingTime != null) 'maxCookingTime': maxCookingTime,
      if (minCalories != null) 'minCalories': minCalories,
      if (maxCalories != null) 'maxCalories': maxCalories,
      if (minProtein != null) 'minProtein': minProtein,
      if (maxProtein != null) 'maxProtein': maxProtein,
      if (minFat != null) 'minFat': minFat,
      if (maxFat != null) 'maxFat': maxFat,
      if (minCarbohydrates != null) 'minCarbohydrates': minCarbohydrates,
      if (maxCarbohydrates != null) 'maxCarbohydrates': maxCarbohydrates,
      if (dietTypes != null && dietTypes.isNotEmpty)
        'dietTypes': dietTypes.join(','),
      if (ingredients != null && ingredients.isNotEmpty)
        'ingredients': ingredients.join(','),
    };
  }

  /// Get all recipes with pagination
  /// Default: status=published, page=1, limit=10
  Future<RecipeListResponse> getAllRecipes({
    int page = 1,
    int limit = 10,
    String? status,
    int? maxCookingTime,
    double? minCalories,
    double? maxCalories,
    double? minProtein,
    double? maxProtein,
    double? minFat,
    double? maxFat,
    double? minCarbohydrates,
    double? maxCarbohydrates,
    List<String>? dietTypes,
    List<String>? ingredients,
  }) async {
    try {
      debugPrint('Fetching recipes - page: $page, limit: $limit');

      final queryParams = {
        'page': page,
        'limit': limit,
        if (status != null) 'status': status,
        ..._buildFilterQueryParams(
          maxCookingTime: maxCookingTime,
          minCalories: minCalories,
          maxCalories: maxCalories,
          minProtein: minProtein,
          maxProtein: maxProtein,
          minFat: minFat,
          maxFat: maxFat,
          minCarbohydrates: minCarbohydrates,
          maxCarbohydrates: maxCarbohydrates,
          dietTypes: dietTypes,
          ingredients: ingredients,
        ),
      };

      final url = '$baseUrl/api/recipes';
      final response = await _dio.get(url, queryParameters: queryParams);

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
    double? minCalories,
    double? maxCalories,
    double? minProtein,
    double? maxProtein,
    double? minFat,
    double? maxFat,
    double? minCarbohydrates,
    double? maxCarbohydrates,
    List<String>? dietTypes,
    List<String>? ingredients,
  }) async {
    try {
      debugPrint('Searching recipes - keyword: "$keyword", page: $page');

      final queryParams = {
        'keyword': keyword,
        'page': page,
        'limit': limit,
        if (status != null) 'status': status,
        ..._buildFilterQueryParams(
          maxCookingTime: maxCookingTime,
          minCalories: minCalories,
          maxCalories: maxCalories,
          minProtein: minProtein,
          maxProtein: maxProtein,
          minFat: minFat,
          maxFat: maxFat,
          minCarbohydrates: minCarbohydrates,
          maxCarbohydrates: maxCarbohydrates,
          dietTypes: dietTypes,
          ingredients: ingredients,
        ),
      };

      final url = '$baseUrl/api/recipes';
      final response = await _dio.get(url, queryParameters: queryParams);

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

      final url = '$baseUrl/api/recipes';
      final response = await _dio.get(url, queryParameters: queryParams);

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

      final url = '$baseUrl/api/recipes/$id';
      final response = await _dio.get(url);

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

      final url = '$baseUrl/api/recipes/$recipeId/nutrition';
      final response = await _dio.get(url);

      final nutritionData = response.data['data'] as Map<String, dynamic>;
      return RecipeNutrition.fromJson(nutritionData);
    } on DioException catch (e) {
      debugPrint('Error fetching nutrition: ${e.response?.data}');
      rethrow;
    }
  }

  // === FAVORITE OPERATIONS ===

  /// Toggle favorite status (add or remove)
  Future<bool> toggleFavorite(String recipeId) async {
    try {
      debugPrint('Toggling favorite - recipe id: $recipeId');

      final url = '$baseUrl/api/recipes/$recipeId/favorite/toggle';
      final response = await _dio.post(url);

      final data = response.data['data'] as Map<String, dynamic>;
      final isFavorited = data['isFavorited'] == true;

      debugPrint('Favorite toggled - isFavorited: $isFavorited');
      return isFavorited;
    } on DioException catch (e) {
      debugPrint('Error toggling favorite: ${e.response?.data}');
      rethrow;
    }
  }

  /// Add recipe to favorites
  Future<void> addFavorite(String recipeId) async {
    try {
      debugPrint('Adding to favorites - recipe id: $recipeId');
      final url = '$baseUrl/api/recipes/$recipeId/favorite';
      await _dio.post(url);
      debugPrint('Added to favorites successfully');
    } on DioException catch (e) {
      debugPrint('Error adding favorite: ${e.response?.data}');
      rethrow;
    }
  }

  /// Remove recipe from favorites
  Future<void> removeFavorite(String recipeId) async {
    try {
      debugPrint('Removing from favorites - recipe id: $recipeId');
      final url = '$baseUrl/api/recipes/$recipeId/favorite';
      await _dio.delete(url);
      debugPrint('Removed from favorites successfully');
    } on DioException catch (e) {
      debugPrint('Error removing favorite: ${e.response?.data}');
      rethrow;
    }
  }

  /// Get user's favorite recipes
  Future<FavoriteRecipesResponse> getFavoriteRecipes({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      debugPrint('Fetching favorite recipes - page: $page');

      final queryParams = {'page': page, 'limit': limit};

      final url = '$baseUrl/api/recipes/favorites';
      final response = await _dio.get(url, queryParameters: queryParams);

      debugPrint(
        'Favorites fetched: ${response.data['data']['pagination']['total']} total',
      );
      return FavoriteRecipesResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      debugPrint('Error fetching favorites: ${e.response?.data}');
      rethrow;
    }
  }

  /// Check if recipe is favorited
  Future<bool> checkFavoriteStatus(String recipeId) async {
    try {
      final url = '$baseUrl/api/recipes/$recipeId/favorite/status';
      final response = await _dio.get(url);
      final data = response.data['data'] as Map<String, dynamic>;
      return data['isFavorited'] == true;
    } on DioException catch (e) {
      debugPrint('Error checking favorite status: ${e.response?.data}');
      return false;
    }
  }

  /// Get count of user's favorite recipes
  Future<int> getFavoriteCount() async {
    try {
      final url = '$baseUrl/api/recipes/favorites/count';
      final response = await _dio.get(url);
      final data = response.data['data'] as Map<String, dynamic>;
      return (data['count'] as num).toInt();
    } on DioException catch (e) {
      debugPrint('Error getting favorite count: ${e.response?.data}');
      return 0;
    }
  }

  // ===== REVIEW API METHODS =====

  /// Add or update a review for a recipe
  Future<RecipeReview> addReview({
    required String recipeId,
    required int rating,
    required String comment,
  }) async {
    try {
      if (rating < 1 || rating > 5) {
        throw Exception('Rating must be between 1 and 5');
      }

      debugPrint(
        'Adding/updating review for recipe: $recipeId, rating: $rating',
      );

      final url = '$baseUrl/api/recipes/$recipeId/reviews';
      final response = await _dio.post(
        url,
        data: {'rating': rating, 'comment': comment},
      );

      debugPrint('Review added/updated successfully');
      final reviewData =
          response.data['data']['review'] as Map<String, dynamic>;
      return RecipeReview.fromJson(reviewData);
    } on DioException catch (e) {
      debugPrint('Error adding review: ${e.response?.data}');
      rethrow;
    }
  }

  /// Get reviews for a specific recipe
  Future<RecipeReviewsResponse> getRecipeReviews({
    required String recipeId,
    int page = 1,
    int limit = 10,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
  }) async {
    try {
      debugPrint('Fetching reviews for recipe: $recipeId');

      final url = '$baseUrl/api/recipes/$recipeId/reviews';
      final response = await _dio.get(
        url,
        queryParameters: {
          'page': page,
          'limit': limit,
          'sortBy': sortBy,
          'sortOrder': sortOrder,
        },
      );

      debugPrint(
        'Reviews fetched: ${response.data['data']['pagination']['total']}',
      );
      return RecipeReviewsResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      debugPrint('Error fetching reviews: ${e.response?.data}');
      rethrow;
    }
  }

  /// Get user's review for a specific recipe
  Future<RecipeReview?> getUserRecipeReview(String recipeId) async {
    try {
      final url = '$baseUrl/api/recipes/$recipeId/reviews/user/mine';
      final response = await _dio.get(url);

      final reviewData = response.data['data']['review'];
      if (reviewData == null) {
        return null;
      }

      return RecipeReview.fromJson(reviewData as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('Error fetching user review: ${e.response?.data}');
      return null;
    }
  }

  /// Get all user's reviews
  Future<UserReviewsResponse> getUserReviews({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      debugPrint('Fetching user reviews - page: $page');

      final url = '$baseUrl/api/recipes/reviews/user/list';
      final response = await _dio.get(
        url,
        queryParameters: {'page': page, 'limit': limit},
      );

      debugPrint(
        'User reviews fetched: ${response.data['data']['pagination']['total']}',
      );
      return UserReviewsResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      debugPrint('Error fetching user reviews: ${e.response?.data}');
      rethrow;
    }
  }

  /// Delete a review
  Future<void> deleteReview({
    required String recipeId,
    required String reviewId,
  }) async {
    try {
      debugPrint('Deleting review: $reviewId');

      final url = '$baseUrl/api/recipes/$recipeId/reviews/$reviewId';
      await _dio.delete(url);

      debugPrint('Review deleted successfully');
    } on DioException catch (e) {
      debugPrint('Error deleting review: ${e.response?.data}');
      rethrow;
    }
  }
}
