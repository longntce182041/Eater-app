import 'package:dio/dio.dart';

import '../domain/home_dashboard_models.dart';

class HomeDashboardApiClient {
  final Dio _dio;
  final String baseUrl;

  HomeDashboardApiClient(this._dio, this.baseUrl);

  /// Get home dashboard data (Today's overview + calories + meals)
  Future<HomeDashboardData> getHomeDashboard() async {
    try {
      final response = await _dio.get(
        '$baseUrl/api/home/dashboard',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return HomeDashboardData.fromJson(response.data);
      } else {
        throw Exception(
            'Failed to load home dashboard: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching home dashboard: $e');
    }
  }

  /// Get upcoming meals for next N days
  Future<UpcomingMealsData> getUpcomingMeals({int days = 7}) async {
    try {
      final response = await _dio.get(
        '$baseUrl/api/home/upcoming-meals',
        queryParameters: {
          'days': days,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return UpcomingMealsData.fromJson(response.data);
      } else {
        throw Exception(
            'Failed to load upcoming meals: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching upcoming meals: $e');
    }
  }
}
