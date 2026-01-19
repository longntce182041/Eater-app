import '../entities/recipe.dart';
import '../repositories/recipe_repository.dart';

class SearchRecipesUseCase {
  final RecipeRepository repository;

  SearchRecipesUseCase(this.repository);

  Future<List<Recipe>> call(String query, {Map<String, dynamic>? filters}) {
    return repository.searchRecipes(query, filters: filters);
  }
}
