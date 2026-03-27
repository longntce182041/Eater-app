import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/meal_log.dart';

class MealLogService {
  final Dio dio;

  MealLogService({required this.dio});

  static const String baseUrl = '/api/meal-logs';

  /// Save a meal log to the backend
  /// Returns the saved meal log with ID from the server
  Future<MealLog> saveMealLog(MealLog mealLog) async {
    try {
      debugPrint(
          '[saveMealLog] Creating meal with loggedAt: ${mealLog.loggedAt.toString()}');

      // Format date string WITHOUT timezone conversion
      // Extract year/month/day from local DateTime, don't use toIso8601String() which converts to UTC
      final year = mealLog.loggedAt.year;
      final month = mealLog.loggedAt.month.toString().padLeft(2, '0');
      final day = mealLog.loggedAt.day.toString().padLeft(2, '0');
      final loggedAtString = '$year-$month-${day}T00:00:00.000Z';
      debugPrint(
          '[saveMealLog] Formatted loggedAt string (no timezone conversion): $loggedAtString');

      final response = await dio.post(
        baseUrl,
        data: {
          'mealName': mealLog.mealName,
          'mealType': mealLog.mealType,
          'calories': mealLog.calories,
          'protein': mealLog.protein,
          'carbs': mealLog.carbs,
          'fats': mealLog.fats,
          'quantity': mealLog.quantity,
          'unit': mealLog.unit,
          'notes': mealLog.notes,
          'imageUrl': mealLog.imageUrl,
          'loggedAt': loggedAtString,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Debug: Print raw response
        debugPrint('[saveMealLog] Response status: ${response.statusCode}');
        debugPrint('[saveMealLog] Full response: ${response.data}');

        // Return the saved meal log (server may return additional fields like ID)
        final data = response.data['data'] ?? response.data;
        debugPrint('[saveMealLog] Parsed data: $data');

        final savedMeal = MealLog.fromJson(data as Map<String, dynamic>);
        debugPrint(
            '[saveMealLog] Parsed MealLog - ID: ${savedMeal.id}, name: ${savedMeal.mealName}, loggedAt: ${savedMeal.loggedAt}');

        return savedMeal;
      } else {
        throw Exception('Failed to save meal log: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('[saveMealLog] DioException: ${e.message}');
      throw Exception('Error saving meal log: ${e.message}');
    } catch (e) {
      debugPrint('[saveMealLog] Exception: $e');
      throw Exception('Unexpected error saving meal log: $e');
    }
  }

  /// Update an existing meal log
  /// Returns the updated meal log
  Future<MealLog> updateMealLog(String mealLogId, MealLog mealLog) async {
    try {
      final response = await dio.put(
        '$baseUrl/$mealLogId',
        data: {
          'mealName': mealLog.mealName,
          'mealType': mealLog.mealType,
          'calories': mealLog.calories,
          'protein': mealLog.protein,
          'carbs': mealLog.carbs,
          'fats': mealLog.fats,
          'quantity': mealLog.quantity,
          'unit': mealLog.unit,
          'notes': mealLog.notes,
          'imageUrl': mealLog.imageUrl,
        },
      );

      if (response.statusCode == 200) {
        // Return the updated meal log
        final data = response.data['data'] ?? response.data;
        return MealLog.fromJson(data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to update meal log: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Error updating meal log: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error updating meal log: $e');
    }
  }

  /// Get meal logs for a specific date
  Future<List<MealLog>> getMealLogsForDate(DateTime date) async {
    try {
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final response = await dio.get('$baseUrl/date/$dateStr');

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        final mealsData = data['meals'] as List<dynamic>? ?? [];
        return mealsData
            .map((m) => MealLog.fromJson(m as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch meal logs: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Error fetching meal logs: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error fetching meal logs: $e');
    }
  }

  /// Get all meal logs with pagination
  Future<List<MealLog>> getAllMealLogs({int page = 1, int limit = 50}) async {
    try {
      final response = await dio.get(
        baseUrl,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        final mealsData = data['meals'] as List<dynamic>? ?? [];
        return mealsData
            .map((m) => MealLog.fromJson(m as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch meal logs: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Error fetching meal logs: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error fetching meal logs: $e');
    }
  }

  /// Delete a meal log
  Future<bool> deleteMealLog(String mealLogId) async {
    try {
      final response = await dio.delete('$baseUrl/$mealLogId');

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete meal log: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Error deleting meal log: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error deleting meal log: $e');
    }
  }
}
