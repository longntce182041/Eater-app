import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/recipe.dart';
import '../repositories/recipe_repository.dart';

/// Use case for searching recipes.
class SearchRecipesUseCase implements UseCase<List<Recipe>, String> {
  final RecipeRepository repository;

  SearchRecipesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Recipe>>> call(String params) {
    return repository.searchRecipes(params);
  }
}
