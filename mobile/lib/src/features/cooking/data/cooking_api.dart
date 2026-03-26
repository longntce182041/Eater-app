import 'package:dio/dio.dart';
import '../domain/cooking_models.dart';

/// API service for interactive cooking feature
class CookingAPI {
  final Dio _dio;
  final String _baseUrl = '/api/recipes';

  CookingAPI(this._dio);

  /// Start a new cooking session
  /// GET /api/recipes/:recipeId/cook/start
  Future<CookingModeData> startCookingSession({
    required String recipeId,
    int servings = 1,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/$recipeId/cook/start',
        queryParameters: {
          'servings': servings,
        },
      );

      final data = (response.data as Map<String, dynamic>);
      return CookingModeData.fromJson(data);
    } catch (e) {
      throw Exception('Failed to start cooking session: $e');
    }
  }

  /// Get current cooking session details
  /// GET /api/recipes/:recipeId/cook/session/:sessionId
  Future<CookingModeData> getCookingSession({
    required String recipeId,
    required String sessionId,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/$recipeId/cook/session/$sessionId',
      );

      final data = (response.data as Map<String, dynamic>);
      return CookingModeData.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get cooking session: $e');
    }
  }

  /// Mark a step as completed
  /// PATCH /api/recipes/:recipeId/cook/session/:sessionId/step/:stepNumber
  Future<void> completeStep({
    required String recipeId,
    required String sessionId,
    required int stepNumber,
    String? notes,
  }) async {
    try {
      await _dio.patch(
        '$_baseUrl/$recipeId/cook/session/$sessionId/step/$stepNumber',
        data: {
          if (notes != null) 'notes': notes,
        },
      );
    } catch (e) {
      throw Exception('Failed to complete step: $e');
    }
  }

  /// Pause the cooking session
  /// POST /api/recipes/:recipeId/cook/session/:sessionId/pause
  Future<void> pauseCookingSession({
    required String recipeId,
    required String sessionId,
  }) async {
    try {
      await _dio.post(
        '$_baseUrl/$recipeId/cook/session/$sessionId/pause',
      );
    } catch (e) {
      throw Exception('Failed to pause cooking session: $e');
    }
  }

  /// Resume the cooking session
  /// POST /api/recipes/:recipeId/cook/session/:sessionId/resume
  Future<void> resumeCookingSession({
    required String recipeId,
    required String sessionId,
  }) async {
    try {
      await _dio.post(
        '$_baseUrl/$recipeId/cook/session/$sessionId/resume',
      );
    } catch (e) {
      throw Exception('Failed to resume cooking session: $e');
    }
  }

  /// Complete the cooking session
  /// POST /api/recipes/:recipeId/cook/session/:sessionId/complete
  Future<void> completeCookingSession({
    required String recipeId,
    required String sessionId,
    String? notes,
  }) async {
    try {
      await _dio.post(
        '$_baseUrl/$recipeId/cook/session/$sessionId/complete',
        data: {
          if (notes != null) 'notes': notes,
        },
      );
    } catch (e) {
      throw Exception('Failed to complete cooking session: $e');
    }
  }

  /// Get all recipe steps with details
  /// GET /api/recipes/:recipeId/steps
  Future<List<RecipeStep>> getRecipeSteps({
    required String recipeId,
    int servings = 1,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/$recipeId/steps',
        queryParameters: {
          'servings': servings,
        },
      );

      final data = (response.data as Map<String, dynamic>);
      final steps = (data['steps'] as List<dynamic>?)
              ?.map((e) => RecipeStep.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];

      return steps;
    } catch (e) {
      throw Exception('Failed to get recipe steps: $e');
    }
  }
}
