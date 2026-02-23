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
}

// Provider
final recipeListProvider =
    StateNotifierProvider<RecipeListNotifier, RecipeListState>((ref) {
      final apiClient = ref.watch(recipeApiClientProvider);
      return RecipeListNotifier(apiClient);
    });
