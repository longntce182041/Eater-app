import 'package:dio/dio.dart';
import '../domain/cooking_models.dart';

/// 🌐 INTERACTIVE COOKING API CLIENT
///
/// Handles all HTTP requests for cooking features:
/// - Starting cooking sessions (begin cooking a recipe)
/// - Retrieving session data (fetch current progress)
/// - Step completion (mark steps as done)
/// - Session control (pause, resume, finish)
/// - Recipe steps (get cooking instructions)
///
/// API Base Path: `/api/recipes`
/// All requests are authenticated via DioProvider (includes JWT token)
///
/// Endpoints:
/// - POST /api/recipes/:recipeId/cook/start - Begin cooking
/// - GET /api/recipes/:recipeId/cook/session/:sessionId - Get session
/// - PATCH /api/recipes/:recipeId/cook/session/:sessionId/step/:stepNumber - Complete step
/// - POST /api/recipes/:recipeId/cook/session/:sessionId/pause - Pause session
/// - POST /api/recipes/:recipeId/cook/session/:sessionId/resume - Resume session
/// - POST /api/recipes/:recipeId/cook/session/:sessionId/complete - Finish cooking
/// - GET /api/recipes/:recipeId/steps - Get all recipe steps
///
/// Example Usage:
/// ```dart
/// final api = CookingAPI(dio);
///
/// // Start cooking a recipe
/// final data = await api.startCookingSession(
///   recipeId: 'recipe_123',
///   servings: 4,
/// );
///
/// // Mark step as complete
/// await api.completeStep(
///   recipeId: data.recipe.id,
///   sessionId: data.session.id,
///   stepNumber: 1,
/// );
/// ```
class CookingAPI {
  final Dio _dio;
  final String _baseUrl = '/api/recipes';

  CookingAPI(this._dio);

  /// 🚀 Start a New Cooking Session
  ///
  /// Endpoint: POST /api/recipes/:recipeId/cook/start
  ///
  /// Flow:
  /// 1. Send recipe ID and servings
  /// 2. Backend initializes cooking session (generates ID, starts timer)
  /// 3. Loads recipe details and all steps
  /// 4. Returns complete CookingModeData
  ///
  /// Query Parameters:
  /// - servings: Number of servings to cook (default: 1, min: 1, max: 20)
  ///
  /// Returns: CookingModeData
  /// - Contains session (ID, timing), recipe info, and all steps
  /// - Ingredients are adjusted for the requested servings
  ///
  /// Throws: Exception if API request fails
  ///
  /// Example Success Response:
  /// ```json
  /// {
  ///   "session": {
  ///     "id": "session_abc123",
  ///     "recipeId": "recipe_pancakes_1",
  ///     "currentStepIndex": 0,
  ///     "completedSteps": [],
  ///     "status": "active",
  ///     "startTime": "2024-03-29T10:00:00Z",
  ///     "elapsedTime": 0,
  ///     "servings": 4
  ///   },
  ///   "recipe": {
  ///     "id": "recipe_pancakes_1",
  ///     "name": "Fluffy Pancakes",
  ///     "cookingTime": 20,
  ///     "baseServings": 2,
  ///     "steps": [...]
  ///   }
  /// }
  /// ```
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

  /// 📖 Get Current Cooking Session Details
  ///
  /// Endpoint: GET /api/recipes/:recipeId/cook/session/:sessionId
  ///
  /// Used to:
  /// - Refresh session data (e.g., after step completion)
  /// - Resume cooking after app close/reopen
  /// - Check current progress and step
  ///
  /// Returns: Complete CookingModeData with current session state
  ///
  /// Throws: Exception if session not found or expired
  ///
  /// Note: Should be called after any session state change to sync with server
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

  /// ✅ Mark a Cooking Step as Completed
  ///
  /// Endpoint: PATCH /api/recipes/:recipeId/cook/session/:sessionId/step/:stepNumber
  ///
  /// Called when user taps "Next Step" button
  ///
  /// Flow:
  /// 1. Sends step completion to server
  /// 2. Backend records step time and marks as complete
  /// 3. Advances session to next step
  ///
  /// Request Body (optional):
  /// - notes: User's notes about this step (e.g., "took longer than expected")
  ///
  /// Throws: Exception if step already completed or session ended
  ///
  /// Note: After completion, call refreshSession() to update local state
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

  /// ⏸️ Pause the Cooking Session
  ///
  /// Endpoint: POST /api/recipes/:recipeId/cook/session/:sessionId/pause
  ///
  /// Called when user taps pause button
  ///
  /// Effects:
  /// - Changes session status from "active" to "paused"
  /// - Timer paused on server side
  /// - Can be resumed later
  ///
  /// Throws: Exception if session already paused or completed
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

  /// ▶️ Resume a Paused Cooking Session
  ///
  /// Endpoint: POST /api/recipes/:recipeId/cook/session/:sessionId/resume
  ///
  /// Called when user taps resume button after pausing
  ///
  /// Effects:
  /// - Changes status from "paused" to "active"
  /// - Resumes timer on server side
  /// - User can continue cooking
  ///
  /// Throws: Exception if session not paused
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

  /// 🎉 Complete the Cooking Session
  ///
  /// Endpoint: POST /api/recipes/:recipeId/cook/session/:sessionId/complete
  ///
  /// Called when user finishes the last step and taps "Finish"
  ///
  /// Request Body (optional):
  /// - notes: User's overall feedback about the recipe
  ///
  /// Effects:
  /// - Changes status to "completed"
  /// - Stops timer
  /// - Records session history
  /// - May log meal to user's nutrition tracking (backend dependent)
  ///
  /// Throws: Exception if session already completed
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

  /// 📋 Get All Recipe Steps with Details
  ///
  /// Endpoint: GET /api/recipes/:recipeId/steps
  ///
  /// Fetches all cooking steps for a recipe with:
  /// - Instructions and estimated times
  /// - Ingredients per step
  /// - Pro tips for each step
  ///
  /// Query Parameters:
  /// - servings: Adjusts ingredient quantities (default: 1)
  ///
  /// Used for:
  /// - Displaying steps in cooking mode
  /// - Meal prep previews
  /// - Recipe details view
  ///
  /// Returns: `List<RecipeStep>`
  /// - Each step has scaled ingredients based on servings
  /// - Estimated times are per step
  ///
  /// Example:
  /// ```dart
  /// final steps = await api.getRecipeSteps(
  ///   recipeId: 'recipe_123',
  ///   servings: 4,
  /// );
  /// ```
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
