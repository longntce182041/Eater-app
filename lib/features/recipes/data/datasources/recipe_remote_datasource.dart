import '../models/recipe_model.dart';

/// Remote data source for recipe operations.
abstract class RecipeRemoteDataSource {
  /// Gets a list of recipes with optional filtering.
  Future<List<RecipeModel>> getRecipes({
    String? category,
    String? cuisineType,
    String? dietaryLabel,
    String? searchQuery,
    int page = 1,
    int limit = 20,
  });

  /// Gets a single recipe by ID.
  Future<RecipeModel> getRecipeById(String id);

  /// Searches recipes by query.
  Future<List<RecipeModel>> searchRecipes(String query);

  /// Gets favorite recipes.
  Future<List<RecipeModel>> getFavoriteRecipes();

  /// Adds a recipe to favorites.
  Future<void> addToFavorites(String recipeId);

  /// Removes a recipe from favorites.
  Future<void> removeFromFavorites(String recipeId);

  /// Gets recipe categories.
  Future<List<String>> getCategories();

  /// Gets recipe cuisine types.
  Future<List<String>> getCuisineTypes();
}
