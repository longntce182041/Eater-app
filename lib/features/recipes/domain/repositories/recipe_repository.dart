import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/recipe.dart';

/// Repository interface for recipe operations.
abstract class RecipeRepository {
  /// Gets a list of recipes with optional filtering.
  Future<Either<Failure, List<Recipe>>> getRecipes({
    String? category,
    String? cuisineType,
    String? dietaryLabel,
    String? searchQuery,
    int page = 1,
    int limit = 20,
  });

  /// Gets a single recipe by ID.
  Future<Either<Failure, Recipe>> getRecipeById(String id);

  /// Searches recipes by query.
  Future<Either<Failure, List<Recipe>>> searchRecipes(String query);

  /// Gets favorite recipes.
  Future<Either<Failure, List<Recipe>>> getFavoriteRecipes();

  /// Adds a recipe to favorites.
  Future<Either<Failure, void>> addToFavorites(String recipeId);

  /// Removes a recipe from favorites.
  Future<Either<Failure, void>> removeFromFavorites(String recipeId);

  /// Gets recipe categories.
  Future<Either<Failure, List<String>>> getCategories();

  /// Gets recipe cuisine types.
  Future<Either<Failure, List<String>>> getCuisineTypes();
}
