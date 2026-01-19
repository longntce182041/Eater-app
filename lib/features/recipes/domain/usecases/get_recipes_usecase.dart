import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/recipe.dart';
import '../repositories/recipe_repository.dart';

/// Use case for getting recipes.
class GetRecipesUseCase implements UseCase<List<Recipe>, GetRecipesParams> {
  final RecipeRepository repository;

  GetRecipesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Recipe>>> call(GetRecipesParams params) {
    return repository.getRecipes(
      category: params.category,
      cuisineType: params.cuisineType,
      dietaryLabel: params.dietaryLabel,
      searchQuery: params.searchQuery,
      page: params.page,
      limit: params.limit,
    );
  }
}

/// Parameters for getting recipes.
class GetRecipesParams {
  final String? category;
  final String? cuisineType;
  final String? dietaryLabel;
  final String? searchQuery;
  final int page;
  final int limit;

  const GetRecipesParams({
    this.category,
    this.cuisineType,
    this.dietaryLabel,
    this.searchQuery,
    this.page = 1,
    this.limit = 20,
  });
}
