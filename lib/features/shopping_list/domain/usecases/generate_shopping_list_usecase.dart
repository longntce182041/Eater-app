import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/shopping_list.dart';
import '../repositories/shopping_list_repository.dart';

/// Use case for generating shopping list from meal plan.
class GenerateShoppingListUseCase implements UseCase<ShoppingList, String> {
  final ShoppingListRepository repository;

  GenerateShoppingListUseCase(this.repository);

  @override
  Future<Either<Failure, ShoppingList>> call(String params) {
    return repository.generateFromMealPlan(params);
  }
}
