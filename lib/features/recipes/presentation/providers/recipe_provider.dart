import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/recipe.dart';

class RecipeState {
  final bool isLoading;
  final List<Recipe> recipes;
  final Recipe? selectedRecipe;
  final String? error;

  RecipeState({
    this.isLoading = false,
    this.recipes = const [],
    this.selectedRecipe,
    this.error,
  });

  RecipeState copyWith({
    bool? isLoading,
    List<Recipe>? recipes,
    Recipe? selectedRecipe,
    String? error,
  }) {
    return RecipeState(
      isLoading: isLoading ?? this.isLoading,
      recipes: recipes ?? this.recipes,
      selectedRecipe: selectedRecipe ?? this.selectedRecipe,
      error: error ?? this.error,
    );
  }
}

class RecipeNotifier extends StateNotifier<RecipeState> {
  RecipeNotifier() : super(RecipeState());

  Future<void> loadRecipes({int page = 1, int limit = 20}) async {
    // TODO: Implement load recipes
  }

  Future<void> searchRecipes(String query) async {
    // TODO: Implement search recipes
  }

  Future<void> loadRecipeDetails(String id) async {
    // TODO: Implement load recipe details
  }
}

final recipeProvider = StateNotifierProvider<RecipeNotifier, RecipeState>((ref) {
  return RecipeNotifier();
});
