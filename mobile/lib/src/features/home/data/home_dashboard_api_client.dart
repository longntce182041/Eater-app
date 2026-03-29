import 'package:dio/dio.dart';

import '../domain/home_dashboard_models.dart';

/// 🌐 HOME DASHBOARD API CLIENT
///
/// Handles all HTTP requests for home dashboard features:
/// - Fetching daily dashboard overview (calories, meals, macros)
/// - Fetching upcoming meals for next N days
///
/// Uses Dio for HTTP requests with automatic token handling
/// (via DioProvider that includes auth interceptor)
///
/// Error Handling:
/// - Throws Exception with descriptive message
/// - Caught by FutureProvider to show error UI
///
/// Example Usage:
/// ```dart
/// final client = HomeDashboardApiClient(dio, 'http://api.example.com');
///
/// // Fetch today's dashboard
/// final dashboard = await client.getHomeDashboard();
///
/// // Fetch next 14 days of meals
/// final meals = await client.getUpcomingMeals(days: 14);
/// ```
class HomeDashboardApiClient {
  final Dio _dio;
  final String baseUrl;

  HomeDashboardApiClient(this._dio, this.baseUrl);

  /// 📊 Fetch Home Dashboard Data
  ///
  /// Endpoint: GET /api/home/dashboard
  ///
  /// Response includes:
  /// - holmeOverview: Today's calorie, meal, and macro progress
  /// - todayMeals: List of meals logged today
  /// - todayStats: Additional metrics (weight, BMI, etc.)
  /// - upcomingMeals: Preview of next few meals
  ///
  /// Returns:
  /// - HomeDashboardData on success (200)
  /// - Exception on error
  ///
  /// Example Response:
  /// ```json
  /// {
  ///   "overview": {
  ///     "calories": {"consumed": 1500, "target": 2000, "percentage": 75},
  ///     "meals": {"consumed": 2, "target": 3},
  ///     "macros": {"protein": 120, "carbohydrates": 150, "fat": 50}
  ///   },
  ///   "todayMeals": [
  ///     {
  ///       "id": "meal_1",
  ///       "mealType": "breakfast",
  ///       "recipeName": "Scrambled Eggs",
  ///       "calories": 350,
  ///       ...
  ///     }
  ///   ],
  ///   ...
  /// }
  /// ```
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

  /// 📅 Fetch Upcoming Meals
  ///
  /// Endpoint: GET /api/home/upcoming-meals?days=7
  ///
  /// Query Parameters:
  /// - days: Number of days ahead to fetch (default: 7, range: 1-30)
  ///
  /// Response includes:
  /// - meals: List of meals grouped by date
  /// - totalNutrition: Aggregated nutrition for period
  /// - suggestions: Meal recommendations
  ///
  /// Returns:
  /// - UpcomingMealsData on success (200)
  /// - Exception on error
  ///
  /// Example Usage:
  /// ```dart
  /// // Get next 7 days (default)
  /// final meals = await client.getUpcomingMeals();
  ///
  /// // Get next 14 days
  /// final twoWeeks = await client.getUpcomingMeals(days: 14);
  ///
  /// // Get tomorrow only
  /// final tomorrow = await client.getUpcomingMeals(days: 1);
  /// ```
  ///
  /// Example Response:
  /// ```json
  /// {
  ///   "meals": [
  ///     {
  ///       "date": "2024-01-16",
  ///       "meals": [
  ///         {
  ///           "id": "meal_1",
  ///           "mealType": "breakfast",
  ///           "recipeName": "Greek Yogurt",
  ///           "calories": 200,
  ///           ...
  ///         }
  ///       ],
  ///       "dayTotals": {"calories": 2000, "protein": 150, ...}
  ///     }
  ///   ],
  ///   "periodTotals": {...}
  /// }
  /// ```
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
