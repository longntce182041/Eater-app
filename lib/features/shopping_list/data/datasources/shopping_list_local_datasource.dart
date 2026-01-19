import '../models/shopping_list_model.dart';

/// Local data source for caching shopping list data.
abstract class ShoppingListLocalDataSource {
  /// Caches shopping lists.
  Future<void> cacheShoppingLists(List<ShoppingListModel> lists);

  /// Gets cached shopping lists.
  Future<List<ShoppingListModel>?> getCachedShoppingLists();

  /// Caches a single shopping list.
  Future<void> cacheShoppingList(ShoppingListModel list);

  /// Gets a cached shopping list by ID.
  Future<ShoppingListModel?> getCachedShoppingListById(String id);

  /// Clears all cached shopping list data.
  Future<void> clearCache();
}
