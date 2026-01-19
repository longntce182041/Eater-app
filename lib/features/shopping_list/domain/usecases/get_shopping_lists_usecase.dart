import '../entities/shopping_list.dart';
import '../repositories/shopping_list_repository.dart';

class GetShoppingListsUseCase {
  final ShoppingListRepository repository;

  GetShoppingListsUseCase(this.repository);

  Future<List<ShoppingList>> call(String userId) {
    return repository.getShoppingLists(userId);
  }
}
