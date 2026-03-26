import 'package:dio/dio.dart';
import '../domain/health_guide_models.dart';

/// API service for health guides feature
class HealthGuidesAPI {
  final Dio _dio;
  final String _baseUrl = '/api/health-guides';

  HealthGuidesAPI(this._dio);

  /// Get all active guides grouped by category
  /// GET /api/health-guides
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

  /// Get guides for a specific category
  /// GET /api/health-guides?category=fasting
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

  /// Get single guide with full content
  /// GET /api/health-guides/:id
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
