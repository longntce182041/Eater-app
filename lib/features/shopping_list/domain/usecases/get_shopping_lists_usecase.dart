import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/shopping_list.dart';
import '../repositories/shopping_list_repository.dart';

/// Use case for getting shopping lists.
class GetShoppingListsUseCase implements UseCase<List<ShoppingList>, NoParams> {
  final ShoppingListRepository repository;

  GetShoppingListsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ShoppingList>>> call(NoParams params) {
    return repository.getShoppingLists();
  }
}
