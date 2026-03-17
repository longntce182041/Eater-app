import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../domain/grocery_models.dart';

/// Local storage service for grocery items
/// Uses flutter_secure_storage for persistent data
/// Data is isolated per userId for multi-user support
class GroceryLocalStorage {
  static const String _baseStorageKey = 'grocery_items';
  final FlutterSecureStorage _storage;

  GroceryLocalStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  /// Generate storage key with userId
  /// This ensures each user has their own grocery list
  String _getStorageKey(String userId) => '${_baseStorageKey}_$userId';

  /// Load all grocery items from storage for specific user
  Future<List<GroceryItem>> loadItems(String userId) async {
    try {
      final String? jsonString = await _storage.read(
        key: _getStorageKey(userId),
      );
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => GroceryItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If error, return empty list (don't crash the app)
      return [];
    }
  }

  /// Save grocery items to storage for specific user
  Future<void> saveItems(String userId, List<GroceryItem> items) async {
    try {
      final jsonList = items.map((item) => item.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await _storage.write(key: _getStorageKey(userId), value: jsonString);
    } catch (e) {
      // Log error but don't throw
      throw Exception('Failed to save grocery items: $e');
    }
  }

  /// Clear all grocery items for specific user
  Future<void> clearAll(String userId) async {
    await _storage.delete(key: _getStorageKey(userId));
  }

  /// Check if storage has items for specific user
  Future<bool> hasItems(String userId) async {
    final String? jsonString = await _storage.read(key: _getStorageKey(userId));
    return jsonString != null && jsonString.isNotEmpty;
  }
}
