import '../entities/recipe.dart';
import '../repositories/recipe_repository.dart';

class GetRecipesUseCase {
  final RecipeRepository repository;

  GetRecipesUseCase(this.repository);

  Future<List<Recipe>> call({int page = 1, int limit = 20}) {
    return repository.getRecipes(page: page, limit: limit);
  }
}
