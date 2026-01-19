import '../entities/recipe.dart';

abstract class RecipeRepository {
  Future<List<Recipe>> getRecipes({int page = 1, int limit = 20});
  Future<Recipe> getRecipeById(String id);
  Future<List<Recipe>> searchRecipes(String query, {Map<String, dynamic>? filters});
  Future<List<Recipe>> getRecipesByTags(List<String> tags);
}
