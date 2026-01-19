import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/shopping_list.dart';
import '../entities/shopping_list_item.dart';

/// Repository interface for shopping list operations.
abstract class ShoppingListRepository {
  /// Gets all shopping lists.
  Future<Either<Failure, List<ShoppingList>>> getShoppingLists();

  /// Gets a shopping list by ID.
  Future<Either<Failure, ShoppingList>> getShoppingListById(String id);

  /// Creates a new shopping list.
  Future<Either<Failure, ShoppingList>> createShoppingList(ShoppingList list);

  /// Generates a shopping list from a meal plan.
  Future<Either<Failure, ShoppingList>> generateFromMealPlan(
    String mealPlanId,
  );

  /// Adds an item to a shopping list.
  Future<Either<Failure, ShoppingListItem>> addItem(ShoppingListItem item);

  /// Updates an item in a shopping list.
  Future<Either<Failure, ShoppingListItem>> updateItem(ShoppingListItem item);

  /// Removes an item from a shopping list.
  Future<Either<Failure, void>> removeItem(String itemId);

  /// Toggles an item's checked status.
  Future<Either<Failure, ShoppingListItem>> toggleItemChecked(String itemId);

  /// Deletes a shopping list.
  Future<Either<Failure, void>> deleteShoppingList(String listId);

  /// Clears all checked items from a list.
  Future<Either<Failure, ShoppingList>> clearCheckedItems(String listId);
}
