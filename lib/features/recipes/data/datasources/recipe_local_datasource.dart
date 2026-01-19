import '../models/recipe_model.dart';

/// Local data source for caching recipe data.
abstract class RecipeLocalDataSource {
  /// Caches a list of recipes.
  Future<void> cacheRecipes(List<RecipeModel> recipes);

  /// Gets cached recipes.
  Future<List<RecipeModel>?> getCachedRecipes();

  /// Caches a single recipe.
  Future<void> cacheRecipe(RecipeModel recipe);

  /// Gets a cached recipe by ID.
  Future<RecipeModel?> getCachedRecipeById(String id);

  /// Caches favorite recipes.
  Future<void> cacheFavoriteRecipes(List<RecipeModel> recipes);

  /// Gets cached favorite recipes.
  Future<List<RecipeModel>?> getCachedFavoriteRecipes();

  /// Clears all cached recipe data.
  Future<void> clearCache();
}
