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

  // === FAVORITE OPERATIONS ===

  /// Toggle favorite status (add or remove)
  Future<bool> toggleFavorite(String recipeId) async {
    try {
      debugPrint('Toggling favorite - recipe id: $recipeId');

      final response = await _dio.post(
        '/api/recipes/$recipeId/favorite/toggle',
      );

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
      await _dio.post('/api/recipes/$recipeId/favorite');
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
      await _dio.delete('/api/recipes/$recipeId/favorite');
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

      final response = await _dio.get(
        '/api/recipes/favorites',
        queryParameters: queryParams,
      );

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
      final response = await _dio.get('/api/recipes/$recipeId/favorite/status');
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
      final response = await _dio.get('/api/recipes/favorites/count');
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

      final response = await _dio.post(
        '/api/recipes/$recipeId/reviews',
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

      final response = await _dio.get(
        '/api/recipes/$recipeId/reviews',
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
      final response = await _dio.get(
        '/api/recipes/$recipeId/reviews/user/mine',
      );

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

      final response = await _dio.get(
        '/api/recipes/reviews/user/list',
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

      await _dio.delete('/api/recipes/$recipeId/reviews/$reviewId');

      debugPrint('Review deleted successfully');
    } on DioException catch (e) {
      debugPrint('Error deleting review: ${e.response?.data}');
      rethrow;
    }
  }
}
