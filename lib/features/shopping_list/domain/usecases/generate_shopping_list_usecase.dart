import '../entities/shopping_list.dart';
import '../repositories/shopping_list_repository.dart';

class GenerateShoppingListFromMealPlanUseCase {
  final ShoppingListRepository repository;

  GenerateShoppingListFromMealPlanUseCase(this.repository);

  Future<ShoppingList> call(String userId, String mealPlanId) {
    return repository.generateFromMealPlan(userId, mealPlanId);
  }
}
