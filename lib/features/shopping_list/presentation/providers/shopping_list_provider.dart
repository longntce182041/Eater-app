import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/shopping_list.dart';

class ShoppingListState {
  final bool isLoading;
  final List<ShoppingList> shoppingLists;
  final ShoppingList? selectedList;
  final String? error;

  ShoppingListState({
    this.isLoading = false,
    this.shoppingLists = const [],
    this.selectedList,
    this.error,
  });

  ShoppingListState copyWith({
    bool? isLoading,
    List<ShoppingList>? shoppingLists,
    ShoppingList? selectedList,
    String? error,
  }) {
    return ShoppingListState(
      isLoading: isLoading ?? this.isLoading,
      shoppingLists: shoppingLists ?? this.shoppingLists,
      selectedList: selectedList ?? this.selectedList,
      error: error ?? this.error,
    );
  }
}

class ShoppingListNotifier extends StateNotifier<ShoppingListState> {
  ShoppingListNotifier() : super(ShoppingListState());

  Future<void> loadShoppingLists(String userId) async {
    // TODO: Implement load shopping lists
  }

  Future<void> createShoppingList(ShoppingList shoppingList) async {
    // TODO: Implement create shopping list
  }

  Future<void> updateShoppingList(ShoppingList shoppingList) async {
    // TODO: Implement update shopping list
  }

  Future<void> deleteShoppingList(String id) async {
    // TODO: Implement delete shopping list
  }

  Future<void> generateFromMealPlan(String userId, String mealPlanId) async {
    // TODO: Implement generate from meal plan
  }
}

final shoppingListProvider = StateNotifierProvider<ShoppingListNotifier, ShoppingListState>((ref) {
  return ShoppingListNotifier();
});
