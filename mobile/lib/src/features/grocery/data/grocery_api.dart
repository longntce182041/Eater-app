import 'package:dio/dio.dart';
import '../domain/grocery_models.dart';

class GroceryApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;

  GroceryApiException({required this.message, this.statusCode, this.code});

  @override
  String toString() => message;
}

/// API client for grocery list operations
/// Communicates with backend: /api/groceries
class GroceryApi {
  final Dio _dio;
  final String baseUrl;

  GroceryApi(this._dio, this.baseUrl);

  /// Add multiple items to grocery list in database
  /// POST /api/groceries
  Future<List<GroceryItem>> addGroceryItems(List<GroceryItem> items) async {
    try {
      final payload = {
        'ingredients': items
            .map(
              (item) => {
                'ingredientId': item.ingredientId,
                'ingredientName': item.name,
                'quantity': item.quantity,
                'unit': item.unit,
                'recipeId': item.recipeId,
                'recipeName': item.recipeName,
                'category': 'Other', // Default category
              },
            )
            .toList(),
      };

      final url = '$baseUrl/api/groceries';
      final response = await _dio.post(url, data: payload);

      if (response.statusCode == 201 && response.data['success'] == true) {
        final List<dynamic> itemsList = response.data['data']['items'] ?? [];
        return itemsList
            .map(
              (item) => _mapResponseToGroceryItem(item as Map<String, dynamic>),
            )
            .toList();
      }
      throw Exception('Failed to add grocery items');
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map<String, dynamic>
          ? (data['message'] as String?)
          : null;
      final code = data is Map<String, dynamic>
          ? (data['code'] as String?)
          : null;

      throw GroceryApiException(
        message: message ?? 'Error adding items: ${e.message}',
        statusCode: e.response?.statusCode,
        code: code,
      );
    }
  }

  /// Get user's grocery list from database
  /// GET /api/groceries
  Future<List<GroceryItem>> getGroceryList({
    int page = 1,
    int limit = 100,
  }) async {
    try {
      final url = '$baseUrl/api/groceries';
      final response = await _dio.get(
        url,
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> itemsList = response.data['data']['items'] ?? [];
        return itemsList
            .map(
              (item) => _mapResponseToGroceryItem(item as Map<String, dynamic>),
            )
            .toList();
      }
      throw Exception('Failed to fetch grocery list');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized');
      }
      throw Exception('Error fetching items: ${e.message}');
    }
  }

  /// Toggle purchase status of an item
  /// PATCH /api/groceries/:itemId/toggle
  Future<GroceryItem> toggleItemStatus(String itemId) async {
    try {
      final url = '$baseUrl/api/groceries/$itemId/toggle';
      final response = await _dio.patch(url);

      if (response.statusCode == 200 && response.data['success'] == true) {
        return _mapResponseToGroceryItem(
          response.data['data'] as Map<String, dynamic>,
        );
      }
      throw Exception('Failed to toggle item status');
    } on DioException catch (e) {
      throw Exception('Error toggling status: ${e.message}');
    }
  }

  /// Remove an item from grocery list
  /// DELETE /api/groceries/:itemId
  Future<void> removeGroceryItem(String itemId) async {
    try {
      final url = '$baseUrl/api/groceries/$itemId';
      final response = await _dio.delete(url);

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception('Failed to remove item');
      }
    } on DioException catch (e) {
      throw Exception('Error removing item: ${e.message}');
    }
  }

  /// Clear all purchased items
  /// DELETE /api/groceries/clear/purchased
  Future<void> clearPurchasedItems() async {
    try {
      final url = '$baseUrl/api/groceries/clear/purchased';
      final response = await _dio.delete(url);

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception('Failed to clear purchased items');
      }
    } on DioException catch (e) {
      throw Exception('Error clearing items: ${e.message}');
    }
  }

  /// Get grocery statistics
  /// GET /api/groceries/stats
  Future<Map<String, dynamic>> getGroceryStats() async {
    try {
      final url = '$baseUrl/api/groceries/stats';
      final response = await _dio.get(url);

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }
      throw Exception('Failed to fetch stats');
    } on DioException catch (e) {
      throw Exception('Error fetching stats: ${e.message}');
    }
  }

  /// Map API response to GroceryItem model
  GroceryItem _mapResponseToGroceryItem(Map<String, dynamic> data) {
    return GroceryItem(
      id: data['id']?.toString() ?? data['_id']?.toString() ?? '',
      ingredientId: data['ingredientId']?.toString() ?? '',
      name: data['ingredientName'] ?? data['name'] ?? '',
      quantity: (data['quantity'] as num?)?.toDouble() ?? 1.0,
      unit: data['unit'] ?? '',
      isPurchased: data['isPurchased'] as bool? ?? false,
      recipeId: data['recipeId']?.toString(),
      recipeName: data['recipeName'] as String?,
      addedAt: data['addedAt'] != null
          ? DateTime.parse(data['addedAt'] as String)
          : DateTime.now(),
    );
  }
}
