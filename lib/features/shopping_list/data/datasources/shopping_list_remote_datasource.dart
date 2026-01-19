import '../models/shopping_list_model.dart';
import '../models/shopping_list_item_model.dart';

/// Remote data source for shopping list operations.
abstract class ShoppingListRemoteDataSource {
  /// Gets all shopping lists.
  Future<List<ShoppingListModel>> getShoppingLists();

  /// Gets a shopping list by ID.
  Future<ShoppingListModel> getShoppingListById(String id);

  /// Creates a new shopping list.
  Future<ShoppingListModel> createShoppingList(ShoppingListModel list);

  /// Generates a shopping list from a meal plan.
  Future<ShoppingListModel> generateFromMealPlan(String mealPlanId);

  /// Adds an item to a shopping list.
  Future<ShoppingListItemModel> addItem(ShoppingListItemModel item);

  /// Updates an item.
  Future<ShoppingListItemModel> updateItem(ShoppingListItemModel item);

  /// Removes an item.
  Future<void> removeItem(String itemId);

  /// Toggles an item's checked status.
  Future<ShoppingListItemModel> toggleItemChecked(String itemId);

  /// Deletes a shopping list.
  Future<void> deleteShoppingList(String listId);

  /// Clears all checked items.
  Future<ShoppingListModel> clearCheckedItems(String listId);
}
