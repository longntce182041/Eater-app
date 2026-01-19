import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/recipe.dart';

/// State for recipes.
class RecipesState {
  final bool isLoading;
  final List<Recipe> recipes;
  final Recipe? selectedRecipe;
  final List<Recipe> favoriteRecipes;
  final List<Recipe> searchResults;
  final String? errorMessage;

  const RecipesState({
    this.isLoading = false,
    this.recipes = const [],
    this.selectedRecipe,
    this.favoriteRecipes = const [],
    this.searchResults = const [],
    this.errorMessage,
  });

  RecipesState copyWith({
    bool? isLoading,
    List<Recipe>? recipes,
    Recipe? selectedRecipe,
    List<Recipe>? favoriteRecipes,
    List<Recipe>? searchResults,
    String? errorMessage,
  }) {
    return RecipesState(
      isLoading: isLoading ?? this.isLoading,
      recipes: recipes ?? this.recipes,
      selectedRecipe: selectedRecipe ?? this.selectedRecipe,
      favoriteRecipes: favoriteRecipes ?? this.favoriteRecipes,
      searchResults: searchResults ?? this.searchResults,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Recipes notifier.
class RecipesNotifier extends StateNotifier<RecipesState> {
  RecipesNotifier() : super(const RecipesState());

  /// Loads recipes.
  Future<void> loadRecipes({
    String? category,
    String? cuisineType,
    String? dietaryLabel,
  }) async {
    state = state.copyWith(isLoading: true);
    // TODO: Implement using GetRecipesUseCase
  }

  /// Gets a recipe by ID.
  Future<void> getRecipeById(String id) async {
    state = state.copyWith(isLoading: true);
    // TODO: Implement using GetRecipeByIdUseCase
  }

  /// Searches recipes.
  Future<void> searchRecipes(String query) async {
    state = state.copyWith(isLoading: true);
    // TODO: Implement using SearchRecipesUseCase
  }

  /// Toggles recipe favorite status.
  Future<void> toggleFavorite(String recipeId) async {
    // TODO: Implement favorite toggle
  }

  /// Loads favorite recipes.
  Future<void> loadFavorites() async {
    // TODO: Implement loading favorites
  }
}

/// Provider for recipes state.
final recipesProvider =
    StateNotifierProvider<RecipesNotifier, RecipesState>((ref) {
  return RecipesNotifier();
});
