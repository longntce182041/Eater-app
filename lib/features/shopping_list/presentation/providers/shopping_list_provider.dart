import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/shopping_list.dart';

/// State for shopping list.
class ShoppingListState {
  final bool isLoading;
  final List<ShoppingList> shoppingLists;
  final ShoppingList? currentList;
  final String? errorMessage;

  const ShoppingListState({
    this.isLoading = false,
    this.shoppingLists = const [],
    this.currentList,
    this.errorMessage,
  });

  ShoppingListState copyWith({
    bool? isLoading,
    List<ShoppingList>? shoppingLists,
    ShoppingList? currentList,
    String? errorMessage,
  }) {
    return ShoppingListState(
      isLoading: isLoading ?? this.isLoading,
      shoppingLists: shoppingLists ?? this.shoppingLists,
      currentList: currentList ?? this.currentList,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Shopping list notifier.
class ShoppingListNotifier extends StateNotifier<ShoppingListState> {
  ShoppingListNotifier() : super(const ShoppingListState());

  /// Loads all shopping lists.
  Future<void> loadShoppingLists() async {
    state = state.copyWith(isLoading: true);
    // TODO: Implement using GetShoppingListsUseCase
  }

  /// Selects a shopping list.
  void selectList(String listId) {
    final list = state.shoppingLists.firstWhere((l) => l.id == listId);
    state = state.copyWith(currentList: list);
  }

  /// Generates a shopping list from meal plan.
  Future<void> generateFromMealPlan(String mealPlanId) async {
    state = state.copyWith(isLoading: true);
    // TODO: Implement using GenerateShoppingListUseCase
  }

  /// Toggles an item's checked status.
  Future<void> toggleItemChecked(String itemId) async {
    // TODO: Implement toggle
  }

  /// Adds an item to the current list.
  Future<void> addItem({
    required String name,
    required double quantity,
    required String unit,
    String? category,
  }) async {
    // TODO: Implement add item
  }

  /// Removes an item from the current list.
  Future<void> removeItem(String itemId) async {
    // TODO: Implement remove item
  }

  /// Clears all checked items.
  Future<void> clearCheckedItems() async {
    // TODO: Implement clear checked
  }
}

/// Provider for shopping list state.
final shoppingListProvider =
    StateNotifierProvider<ShoppingListNotifier, ShoppingListState>((ref) {
  return ShoppingListNotifier();
});
