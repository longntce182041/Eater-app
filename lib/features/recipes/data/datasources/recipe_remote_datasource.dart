import 'package:dio/dio.dart';
import '../models/recipe_model.dart';

abstract class RecipeRemoteDataSource {
  Future<List<RecipeModel>> getRecipes({int page = 1, int limit = 20});
  Future<RecipeModel> getRecipeById(String id);
  Future<List<RecipeModel>> searchRecipes(String query, {Map<String, dynamic>? filters});
  Future<List<RecipeModel>> getRecipesByTags(List<String> tags);
}

class RecipeRemoteDataSourceImpl implements RecipeRemoteDataSource {
  final Dio dio;

  RecipeRemoteDataSourceImpl(this.dio);

  @override
  Future<List<RecipeModel>> getRecipes({int page = 1, int limit = 20}) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  @override
  Future<RecipeModel> getRecipeById(String id) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  @override
  Future<List<RecipeModel>> searchRecipes(String query, {Map<String, dynamic>? filters}) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  @override
  Future<List<RecipeModel>> getRecipesByTags(List<String> tags) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }
}
