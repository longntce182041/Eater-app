import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../datasources/recipe_remote_datasource.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final RecipeRemoteDataSource remoteDataSource;

  RecipeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Recipe>> getRecipes({int page = 1, int limit = 20}) async {
    // TODO: Implement get recipes logic
    throw UnimplementedError();
  }

  @override
  Future<Recipe> getRecipeById(String id) async {
    // TODO: Implement get recipe by id logic
    throw UnimplementedError();
  }

  @override
  Future<List<Recipe>> searchRecipes(String query, {Map<String, dynamic>? filters}) async {
    // TODO: Implement search recipes logic
    throw UnimplementedError();
  }

  @override
  Future<List<Recipe>> getRecipesByTags(List<String> tags) async {
    // TODO: Implement get recipes by tags logic
    throw UnimplementedError();
  }
}
