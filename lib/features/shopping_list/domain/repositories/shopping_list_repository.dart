import '../entities/shopping_list.dart';

abstract class ShoppingListRepository {
  Future<List<ShoppingList>> getShoppingLists(String userId);
  Future<ShoppingList> getShoppingListById(String id);
  Future<ShoppingList> createShoppingList(ShoppingList shoppingList);
  Future<ShoppingList> updateShoppingList(ShoppingList shoppingList);
  Future<void> deleteShoppingList(String id);
  Future<ShoppingList> addItemToList(String listId, ShoppingListItem item);
  Future<ShoppingList> updateItem(String listId, ShoppingListItem item);
  Future<void> deleteItem(String listId, String itemId);
  Future<ShoppingList> generateFromMealPlan(String userId, String mealPlanId);
}
