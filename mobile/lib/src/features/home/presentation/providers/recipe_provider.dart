import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/recipe_api_client.dart';
import '../../domain/recipe_models.dart';

// Recipe List State
class RecipeListState {
  final List<Recipe> recipes;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int totalPages;
  final bool hasMore;
  final String? searchKeyword;

  RecipeListState({
    this.recipes = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasMore = false,
    this.searchKeyword,
  });

  RecipeListState copyWith({
    List<Recipe>? recipes,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
    String? searchKeyword,
  }) {
    return RecipeListState(
      recipes: recipes ?? this.recipes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
      searchKeyword: searchKeyword ?? this.searchKeyword,
    );
  }

  bool get isEmpty => recipes.isEmpty && !isLoading;
  bool get isSearching => searchKeyword != null && searchKeyword!.isNotEmpty;
}

// Recipe List Notifier
class RecipeListNotifier extends StateNotifier<RecipeListState> {
  final RecipeApiClient _apiClient;

  RecipeListNotifier(this._apiClient) : super(RecipeListState());

  // Load initial recipes
  Future<void> loadRecipes({bool refresh = false}) async {
    if (refresh) {
      state = RecipeListState(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final response = await _apiClient.getAllRecipes(page: 1, limit: 20);

      state = state.copyWith(
        recipes: response.recipes,
        isLoading: false,
        currentPage: response.page,
        totalPages: response.totalPages,
        hasMore: response.hasMore,
        error: null,
      );

      debugPrint('Loaded ${response.recipes.length} recipes');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load recipes: $e',
      );
      debugPrint('Error loading recipes: $e');
    }
  }

  // Search recipes
  Future<void> searchRecipes(String keyword) async {
    if (keyword.trim().isEmpty) {
      // If search is cleared, reload all recipes
      await loadRecipes(refresh: true);
      return;
    }

    state = state.copyWith(
      isLoading: true,
      error: null,
      searchKeyword: keyword,
    );

    try {
      final response = await _apiClient.searchRecipes(
        keyword: keyword,
        page: 1,
        limit: 20,
      );

      state = state.copyWith(
        recipes: response.recipes,
        isLoading: false,
        currentPage: response.page,
        totalPages: response.totalPages,
        hasMore: response.hasMore,
        error: null,
      );

      debugPrint('Search "$keyword" found ${response.recipes.length} recipes');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to search recipes: $e',
      );
      debugPrint('Error searching recipes: $e');
    }
  }

  // Load more recipes (pagination)
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    final nextPage = state.currentPage + 1;
    debugPrint('Loading page $nextPage');

    try {
      final response = state.isSearching
          ? await _apiClient.searchRecipes(
              keyword: state.searchKeyword!,
              page: nextPage,
              limit: 20,
            )
          : await _apiClient.getAllRecipes(page: nextPage, limit: 20);

      state = state.copyWith(
        recipes: [...state.recipes, ...response.recipes],
        currentPage: response.page,
        totalPages: response.totalPages,
        hasMore: response.hasMore,
      );

      debugPrint('Loaded more: now ${state.recipes.length} total recipes');
    } catch (e) {
      debugPrint('Error loading more recipes: $e');
    }
  }

  // Filter by cooking time
  Future<void> filterByTime(int? maxMinutes) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      if (maxMinutes == null) {
        // Clear filter
        await loadRecipes(refresh: true);
        return;
      }

      final response = await _apiClient.getQuickMeals(
        maxMinutes: maxMinutes,
        page: 1,
        limit: 20,
      );

      state = state.copyWith(
        recipes: response.recipes,
        isLoading: false,
        currentPage: response.page,
        totalPages: response.totalPages,
        hasMore: response.hasMore,
        error: null,
      );

      debugPrint(
        'Filtered: ${response.recipes.length} recipes under $maxMinutes min',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to filter recipes: $e',
      );
      debugPrint('Error filtering recipes: $e');
    }
  }

  // Clear search
  void clearSearch() {
    loadRecipes(refresh: true);
  }

  // Sync favorite status with a list of favorite recipe IDs
  void syncFavoriteStatus(Set<String> favoriteIds) {
    final updatedRecipes = state.recipes.map((recipe) {
      return recipe.copyWith(isFavorited: favoriteIds.contains(recipe.id));
    }).toList();

    state = state.copyWith(recipes: updatedRecipes);
    debugPrint('Synced favorite status for ${state.recipes.length} recipes');
  }

  // Toggle favorite status
  Future<void> toggleFavorite(String recipeId) async {
    try {
      final isFavorited = await _apiClient.toggleFavorite(recipeId);

      // Update local state
      final updatedRecipes = state.recipes.map((recipe) {
        if (recipe.id == recipeId) {
          return recipe.copyWith(isFavorited: isFavorited);
        }
        return recipe;
      }).toList();

      state = state.copyWith(recipes: updatedRecipes);

      debugPrint('Recipe $recipeId favorite status: $isFavorited');
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      rethrow;
    }
  }
}

// Provider
final recipeListProvider =
    StateNotifierProvider<RecipeListNotifier, RecipeListState>((ref) {
      final apiClient = ref.watch(recipeApiClientProvider);
      return RecipeListNotifier(apiClient);
    });

// === FAVORITE RECIPES ===

// Favorite Recipes State
class FavoriteRecipesState {
  final List<FavoriteRecipe> favorites;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final bool hasMore;

  FavoriteRecipesState({
    this.favorites = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = false,
  });

  FavoriteRecipesState copyWith({
    List<FavoriteRecipe>? favorites,
    bool? isLoading,
    String? error,
    int? currentPage,
    bool? hasMore,
  }) {
    return FavoriteRecipesState(
      favorites: favorites ?? this.favorites,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  bool get isEmpty => favorites.isEmpty && !isLoading;
}

// Favorite Recipes Notifier
class FavoriteRecipesNotifier extends StateNotifier<FavoriteRecipesState> {
  final RecipeApiClient _apiClient;

  FavoriteRecipesNotifier(this._apiClient) : super(FavoriteRecipesState());

  // Load favorite recipes
  Future<void> loadFavorites({bool refresh = false}) async {
    if (refresh) {
      state = FavoriteRecipesState(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final response = await _apiClient.getFavoriteRecipes(page: 1, limit: 20);

      state = state.copyWith(
        favorites: response.favorites,
        isLoading: false,
        currentPage: response.page,
        hasMore: response.hasMore,
        error: null,
      );

      debugPrint('Loaded ${response.favorites.length} favorite recipes');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load favorites: $e',
      );
      debugPrint('Error loading favorites: $e');
    }
  }

  // Load more favorites
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    final nextPage = state.currentPage + 1;

    try {
      final response = await _apiClient.getFavoriteRecipes(
        page: nextPage,
        limit: 20,
      );

      state = state.copyWith(
        favorites: [...state.favorites, ...response.favorites],
        currentPage: response.page,
        hasMore: response.hasMore,
      );

      debugPrint('Loaded more favorites: ${state.favorites.length} total');
    } catch (e) {
      debugPrint('Error loading more favorites: $e');
    }
  }

  // Remove from favorites (update local state)
  void removeLocal(String recipeId) {
    final updatedFavorites = state.favorites
        .where((fav) => fav.recipe.id != recipeId)
        .toList();

    state = state.copyWith(favorites: updatedFavorites);
  }
}

// Favorite Recipes Provider
final favoriteRecipesProvider =
    StateNotifierProvider<FavoriteRecipesNotifier, FavoriteRecipesState>((ref) {
      final apiClient = ref.watch(recipeApiClientProvider);
      return FavoriteRecipesNotifier(apiClient);
    });

// Favorite count provider
final favoriteCountProvider = FutureProvider<int>((ref) async {
  final apiClient = ref.watch(recipeApiClientProvider);
  return apiClient.getFavoriteCount();
});

// Nutrition Provider
final recipeNutritionProvider = FutureProvider.family<RecipeNutrition, String>((
  ref,
  recipeId,
) async {
  final apiClient = ref.watch(recipeApiClientProvider);
  return apiClient.getRecipeNutrition(recipeId);
});
