import 'package:dio/dio.dart';
import '../domain/health_guide_models.dart';

/// 🌐 HEALTH GUIDES API CLIENT
///
/// Handles all HTTP requests for health guides feature:
/// - Fetch all guides grouped by category
/// - Fetch guides by specific category
/// - Fetch single guide with full content
///
/// API Base Path: `/api/health-guides`
/// All requests are authenticated via DioProvider (includes JWT token)
///
/// Endpoints:
/// - GET /api/health-guides - Get all guides by category
/// - GET /api/health-guides?category=fasting - Filter by category
/// - GET /api/health-guides/:id - Get single guide
///
/// Example Usage:
/// ```dart
/// final api = HealthGuidesAPI(dio);
///
/// // Get all guides grouped by category
/// final categories = await api.getAllGuidesByCategory();
///
/// // Get guides for specific category
/// final fastingGuides = await api.getGuidesByCategory(category: 'fasting');
///
/// // Get full guide content
/// final guide = await api.getGuideDetail(guideId: 'guide_123');
/// ```
class HealthGuidesAPI {
  final Dio _dio;
  final String _baseUrl = '/api/health-guides';

  HealthGuidesAPI(this._dio);

  /// 📚 Fetch All Health Guides Grouped by Category
  ///
  /// Endpoint: GET /api/health-guides
  ///
  /// Purpose:
  /// - Load all available guides at once
  /// - Group by category server-side
  /// - Used when initializing health guides screen
  ///
  /// Returns: `List<HealthGuideCategory>`
  /// - Each category contains list of guides
  /// - Guides include preview (no full content)
  ///
  /// Response Structure:
  /// ```json
  /// {
  ///   "data": [
  ///     {
  ///       "category": "fasting",
  ///       "guides": [
  ///         {
  ///           "id": "guide_1",
  ///           "title": "16:8 Intermittent Fasting",
  ///           "description": "Learn the basics...",
  ///           "category": "fasting",
  ///           "estimatedReadTime": 8,
  ///           "tags": ["fasting", "beginner"],
  ///           "difficulty": "beginner"
  ///         }
  ///       ]
  ///     },
  ///     {
  ///       "category": "nutrition",
  ///       "guides": [...]
  ///     }
  ///   ]
  /// }
  /// ```
  ///
  /// Used by: allHealthGuidesProvider
  ///
  /// Throws: Exception if API request fails
  Future<List<HealthGuideCategory>> getAllGuidesByCategory() async {
    try {
      final response = await _dio.get(_baseUrl);

      final data = (response.data as Map<String, dynamic>);
      final categoriesData = (data['data'] as List<dynamic>?) ?? [];

      return categoriesData
          .map((e) => HealthGuideCategory.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch health guides: $e');
    }
  }

  /// 🔍 Fetch Guides for a Specific Category
  ///
  /// Endpoint: GET /api/health-guides?category=fasting
  ///
  /// Query Parameters:
  /// - category: Category identifier (fasting, nutrition, workouts, etc.)
  ///
  /// Purpose:
  /// - Lazy load guides when user selects category
  /// - Filter server-side instead of client-side
  /// - Reduce data transfer
  ///
  /// Returns: HealthGuideCategory
  /// - Single category with filtered guides
  /// - Same structure as getAllGuidesByCategory
  ///
  /// Example:
  /// ```dart
  /// // Get all fasting guides
  /// final fasting = await api.getGuidesByCategory(category: 'fasting');
  /// // fasting.guides contains all fasting guides
  ///
  /// // Get nutrition guides
  /// final nutrition = await api.getGuidesByCategory(category: 'nutrition');
  /// ```
  ///
  /// Response:
  /// ```json
  /// {
  ///   "data": {
  ///     "category": "fasting",
  ///     "guides": [
  ///       {...}, {...}, ...
  ///     ]
  ///   }
  /// }
  /// ```
  ///
  /// Throws: Exception if category doesn't exist or API fails
  Future<HealthGuideCategory> getGuidesByCategory({
    required String category,
  }) async {
    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'category': category,
        },
      );

      final data = (response.data as Map<String, dynamic>);
      final categoryData = (data['data'] as Map<String, dynamic>);

      return HealthGuideCategory.fromJson(categoryData);
    } catch (e) {
      throw Exception('Failed to fetch guides for category: $e');
    }
  }

  /// 📖 Fetch Single Guide with Full Content
  ///
  /// Endpoint: GET /api/health-guides/:id
  ///
  /// Path Parameters:
  /// - guideId: Unique guide identifier
  ///
  /// Purpose:
  /// - Load full guide content when user taps guide card
  /// - Fetch separately from list to reduce initial payload
  /// - Include full markdown/HTML content
  ///
  /// Returns: HealthGuide
  /// - Complete guide with full content field populated
  /// - All metadata (tags, difficulty, read time)
  ///
  /// Response includes:
  /// ```json
  /// {
  ///   "data": {
  ///     "id": "guide_123",
  ///     "title": "16:8 Intermittent Fasting",
  ///     "description": "Learn the basics...",
  ///     "content": "Intermittent fasting is a pattern that cycles...",
  ///     "category": "fasting",
  ///     "estimatedReadTime": 8,
  ///     "tags": ["fasting", "beginner", "nutrition"],
  ///     "difficulty": "beginner"
  ///   }
  /// }
  /// ```
  ///
  /// Used by: guideDetailProvider (family provider)
  ///
  /// Example:
  /// ```dart
  /// // Fetch guide when user taps card
  /// final guide = await api.getGuideDetail(guideId: 'guide_123');
  /// // Now guide.content contains full article text
  /// ```
  ///
  /// Throws: Exception if guide not found or API fails
  Future<HealthGuide> getGuideDetail({required String guideId}) async {
    try {
      final response = await _dio.get('$_baseUrl/$guideId');

      final data = (response.data as Map<String, dynamic>);
      final guideData = (data['data'] as Map<String, dynamic>);

      return HealthGuide.fromJson(guideData);
    } catch (e) {
      throw Exception('Failed to fetch guide details: $e');
    }
  }
}
