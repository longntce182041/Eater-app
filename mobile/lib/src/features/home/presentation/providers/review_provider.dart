import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/recipe_api_client.dart';
import '../../domain/recipe_models.dart';

// === STATES ===

class RecipeReviewsState {
  final List<RecipeReviewDetail> reviews;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final bool hasMore;
  final RatingStats? stats;

  RecipeReviewsState({
    this.reviews = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = false,
    this.stats,
  });

  RecipeReviewsState copyWith({
    List<RecipeReviewDetail>? reviews,
    bool? isLoading,
    String? error,
    int? currentPage,
    bool? hasMore,
    RatingStats? stats,
  }) {
    return RecipeReviewsState(
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      stats: stats ?? this.stats,
    );
  }

  bool get isEmpty => reviews.isEmpty && !isLoading;
}

class UserReviewsState {
  final List<UserReviewItem> reviews;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final bool hasMore;

  UserReviewsState({
    this.reviews = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = false,
  });

  UserReviewsState copyWith({
    List<UserReviewItem>? reviews,
    bool? isLoading,
    String? error,
    int? currentPage,
    bool? hasMore,
  }) {
    return UserReviewsState(
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  bool get isEmpty => reviews.isEmpty && !isLoading;
}

// === NOTIFIERS ===

class RecipeReviewsNotifier extends StateNotifier<RecipeReviewsState> {
  final RecipeApiClient _apiClient;
  final String recipeId;

  RecipeReviewsNotifier(this._apiClient, this.recipeId)
    : super(RecipeReviewsState());

  // Load reviews for a recipe
  Future<void> loadReviews({bool refresh = false}) async {
    if (refresh) {
      state = RecipeReviewsState();
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final response = await _apiClient.getRecipeReviews(
        recipeId: recipeId,
        page: 1,
        limit: 10,
      );

      state = state.copyWith(
        reviews: response.reviews,
        isLoading: false,
        currentPage: response.page,
        hasMore: response.hasMore,
        stats: response.stats,
        error: null,
      );

      debugPrint('Loaded ${response.reviews.length} reviews');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load reviews: $e',
      );
      debugPrint('Error loading reviews: $e');
    }
  }

  // Load more reviews (pagination)
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    final nextPage = state.currentPage + 1;

    try {
      final response = await _apiClient.getRecipeReviews(
        recipeId: recipeId,
        page: nextPage,
        limit: 10,
      );

      state = state.copyWith(
        reviews: [...state.reviews, ...response.reviews],
        currentPage: response.page,
        hasMore: response.hasMore,
      );

      debugPrint('Loaded more reviews: ${state.reviews.length} total');
    } catch (e) {
      debugPrint('Error loading more reviews: $e');
    }
  }

  // Add a new review
  Future<void> addReview(int rating, String comment) async {
    try {
      await _apiClient.addReview(
        recipeId: recipeId,
        rating: rating,
        comment: comment,
      );

      // Reload reviews to get the full list with the new review
      await loadReviews(refresh: true);

      debugPrint('Review added successfully');
    } catch (e) {
      state = state.copyWith(error: 'Failed to add review: $e');
      debugPrint('Error adding review: $e');
      rethrow;
    }
  }

  // Delete a review
  Future<void> deleteReview(String reviewId) async {
    try {
      await _apiClient.deleteReview(recipeId: recipeId, reviewId: reviewId);

      // Remove from local state
      final updatedReviews = state.reviews
          .where((review) => review.reviewId != reviewId)
          .toList();

      state = state.copyWith(reviews: updatedReviews);

      debugPrint('Review deleted successfully');
    } catch (e) {
      debugPrint('Error deleting review: $e');
      rethrow;
    }
  }
}

class UserReviewsNotifier extends StateNotifier<UserReviewsState> {
  final RecipeApiClient _apiClient;

  UserReviewsNotifier(this._apiClient) : super(UserReviewsState());

  // Load user's reviews
  Future<void> loadUserReviews({bool refresh = false}) async {
    if (refresh) {
      state = UserReviewsState(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final response = await _apiClient.getUserReviews(page: 1, limit: 10);

      state = state.copyWith(
        reviews: response.reviews,
        isLoading: false,
        currentPage: response.page,
        hasMore: response.hasMore,
        error: null,
      );

      debugPrint('Loaded ${response.reviews.length} user reviews');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load reviews: $e',
      );
      debugPrint('Error loading user reviews: $e');
    }
  }

  // Load more user reviews
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    final nextPage = state.currentPage + 1;

    try {
      final response = await _apiClient.getUserReviews(
        page: nextPage,
        limit: 10,
      );

      state = state.copyWith(
        reviews: [...state.reviews, ...response.reviews],
        currentPage: response.page,
        hasMore: response.hasMore,
      );

      debugPrint('Loaded more user reviews: ${state.reviews.length} total');
    } catch (e) {
      debugPrint('Error loading more user reviews: $e');
    }
  }
}

// === PROVIDERS ===

final recipeReviewsProvider =
    StateNotifierProvider.family<
      RecipeReviewsNotifier,
      RecipeReviewsState,
      String
    >((ref, recipeId) {
      final apiClient = ref.watch(recipeApiClientProvider);
      return RecipeReviewsNotifier(apiClient, recipeId);
    });

final userReviewsProvider =
    StateNotifierProvider<UserReviewsNotifier, UserReviewsState>((ref) {
      final apiClient = ref.watch(recipeApiClientProvider);
      return UserReviewsNotifier(apiClient);
    });

// Get user's review for a specific recipe
final userRecipeReviewProvider = FutureProvider.family<RecipeReview?, String>((
  ref,
  recipeId,
) async {
  final apiClient = ref.watch(recipeApiClientProvider);
  return apiClient.getUserRecipeReview(recipeId);
});
