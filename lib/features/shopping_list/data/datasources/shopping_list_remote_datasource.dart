import 'package:dio/dio.dart';
import '../models/shopping_list_model.dart';

abstract class ShoppingListRemoteDataSource {
  Future<List<ShoppingListModel>> getShoppingLists(String userId);
  Future<ShoppingListModel> getShoppingListById(String id);
  Future<ShoppingListModel> createShoppingList(ShoppingListModel shoppingList);
  Future<ShoppingListModel> updateShoppingList(ShoppingListModel shoppingList);
  Future<void> deleteShoppingList(String id);
  Future<ShoppingListModel> addItemToList(String listId, ShoppingListItemModel item);
  Future<ShoppingListModel> updateItem(String listId, ShoppingListItemModel item);
  Future<void> deleteItem(String listId, String itemId);
  Future<ShoppingListModel> generateFromMealPlan(String userId, String mealPlanId);
}

class ShoppingListRemoteDataSourceImpl implements ShoppingListRemoteDataSource {
  final Dio dio;

  ShoppingListRemoteDataSourceImpl(this.dio);

  @override
  Future<List<ShoppingListModel>> getShoppingLists(String userId) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  @override
  Future<ShoppingListModel> getShoppingListById(String id) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  @override
  Future<ShoppingListModel> createShoppingList(ShoppingListModel shoppingList) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  @override
  Future<ShoppingListModel> updateShoppingList(ShoppingListModel shoppingList) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  @override
  Future<void> deleteShoppingList(String id) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  @override
  Future<ShoppingListModel> addItemToList(String listId, ShoppingListItemModel item) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  @override
  Future<ShoppingListModel> updateItem(String listId, ShoppingListItemModel item) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  @override
  Future<void> deleteItem(String listId, String itemId) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  @override
  Future<ShoppingListModel> generateFromMealPlan(String userId, String mealPlanId) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }
}
