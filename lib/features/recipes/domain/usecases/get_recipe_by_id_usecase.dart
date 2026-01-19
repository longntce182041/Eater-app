import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/recipe.dart';
import '../repositories/recipe_repository.dart';

/// Use case for getting a recipe by ID.
class GetRecipeByIdUseCase implements UseCase<Recipe, String> {
  final RecipeRepository repository;

  GetRecipeByIdUseCase(this.repository);

  @override
  Future<Either<Failure, Recipe>> call(String params) {
    return repository.getRecipeById(params);
  }
}
