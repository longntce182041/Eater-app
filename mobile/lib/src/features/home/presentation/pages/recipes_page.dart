import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/recipe_models.dart';
import '../providers/recipe_provider.dart';
import '../providers/review_provider.dart';
import '../widgets/rating_widgets.dart';
import '../widgets/recipe_widgets.dart';
import '../../data/recipe_ingredients_api.dart';
import '../../../grocery/domain/grocery_models.dart';
import '../../../grocery/presentation/providers/grocery_list_provider.dart';
import '../../../../core/utils/notification_service.dart';
import '../../../cooking/presentation/pages/cooking_mode_screen.dart';

/// Provider to track which recipes are currently being added to grocery list
final addingRecipeProvider = StateProvider<Set<String>>((ref) => {});

class RecipesPage extends ConsumerStatefulWidget {
  const RecipesPage({super.key});

  @override
  ConsumerState<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends ConsumerState<RecipesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  RecipeFilter _activeFilter = const RecipeFilter();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load recipes and sync with favorites when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Load recipes first
      await ref.read(recipeListProvider.notifier).loadRecipes();

      // Load favorites to sync status
      await ref.read(favoriteRecipesProvider.notifier).loadFavorites();

      // Sync favorite status in recipes list
      if (mounted) {
        final favoritesState = ref.read(favoriteRecipesProvider);
        final favoriteIds =
            favoritesState.favorites.map((fav) => fav.recipe.id).toSet();
        ref.read(recipeListProvider.notifier).syncFavoriteStatus(favoriteIds);
      }
    });

    // Listen to tab changes and load data
    _tabController.addListener(() {
      if (_tabController.index == 1 && !_tabController.indexIsChanging) {
        ref.read(favoriteRecipesProvider.notifier).loadFavorites();
      }
      if (_tabController.index == 2 && !_tabController.indexIsChanging) {
        ref.read(userReviewsProvider.notifier).loadUserReviews();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String keyword) {
    if (keyword.trim().isEmpty) {
      ref.read(recipeListProvider.notifier).clearSearch();
    } else {
      ref.read(recipeListProvider.notifier).searchRecipes(keyword);
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _FilterBottomSheet(
          initialFilter: _activeFilter,
          onFilterApplied: (RecipeFilter filter) {
            setState(() {
              _activeFilter = filter;
            });
            ref.read(recipeListProvider.notifier).applyFilters(filter);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipeState = ref.watch(recipeListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(140),
          child: Column(
            children: [
              // Search bar and filter button
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearch,
                          style: const TextStyle(
                            color: Color(0xFF000000),
                            fontSize: 16,
                          ),
                          cursorColor: const Color(0xFF000000),
                          decoration: InputDecoration(
                            hintText: 'Search',
                            hintStyle: TextStyle(
                              color: const Color.fromARGB(255, 0, 0, 0),
                              fontSize: 16,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: const Color.fromARGB(255, 0, 0, 0),
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      _onSearch('');
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Filter button
                    Container(
                      decoration: BoxDecoration(
                        color: _activeFilter.hasAnyFilter
                            ? const Color(0xFFE65100)
                            : const Color(0xFFFF9800),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: IconButton(
                        icon: Icon(
                          _activeFilter.hasAnyFilter
                              ? Icons.tune
                              : Icons.tune_outlined,
                          color: Colors.white,
                        ),
                        onPressed: _showFilterDialog,
                      ),
                    ),
                  ],
                ),
              ),

              // Tabs
              TabBar(
                controller: _tabController,
                labelColor: const Color(0xFFFF9800),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFFFF9800),
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                tabs: const [
                  Tab(text: 'Discover'),
                  Tab(text: 'Favorites'),
                  Tab(text: 'Rated'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Discover tab - show all recipes
          _buildDiscoverTab(recipeState),

          // Favorites tab - show favorite recipes
          _buildFavoritesTab(),

          // Rated tab - show user reviews
          _buildRatedTab(),
        ],
      ),
    );
  }

  Widget _buildDiscoverTab(RecipeListState state) {
    if (state.isLoading && state.recipes.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF9800)),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              state.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(recipeListProvider.notifier)
                    .loadRecipes(refresh: true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9800),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(recipeListProvider.notifier).loadRecipes(refresh: true);
      },
      color: const Color(0xFFFF9800),
      child: CustomScrollView(
        slivers: [
          // Import recipe card
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[300]!, width: 2),
              ),
              child: Column(
                children: [
                  const Text(
                    'Import recipe',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 32,
                      color: Color(0xFF999999),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'From link, text, or photos',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),

          // Recipe grid
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                if (index >= state.recipes.length) {
                  return null;
                }

                final recipe = state.recipes[index];

                // Load more when reaching near the end
                if (index == state.recipes.length - 2 &&
                    state.hasMore &&
                    !state.isLoading) {
                  Future.microtask(
                    () => ref.read(recipeListProvider.notifier).loadMore(),
                  );
                }

                return RecipeCard(
                  recipe: recipe,
                  onTap: () => _showRecipeDetail(recipe),
                  isFavorite: recipe.isFavorited,
                  onFavorite: () => _handleFavoriteToggle(recipe),
                );
              }, childCount: state.recipes.length),
            ),
          ),

          // Loading indicator at bottom
          if (state.isLoading && state.recipes.isNotEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFFFF9800)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFavoritesTab() {
    final favoritesState = ref.watch(favoriteRecipesProvider);

    if (favoritesState.isLoading && favoritesState.favorites.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF9800)),
      );
    }

    if (favoritesState.isEmpty) {
      return _buildPlaceholderTab(
        'No favorites yet',
        'Tap the heart icon on recipes to save them here',
        Icons.favorite_border,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(favoriteRecipesProvider.notifier)
            .loadFavorites(refresh: true);
      },
      color: const Color(0xFFFF9800),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                if (index >= favoritesState.favorites.length) {
                  return null;
                }

                final favorite = favoritesState.favorites[index];
                final recipe = favorite.recipe;

                // Load more when reaching near the end
                if (index == favoritesState.favorites.length - 2 &&
                    favoritesState.hasMore &&
                    !favoritesState.isLoading) {
                  Future.microtask(
                    () => ref.read(favoriteRecipesProvider.notifier).loadMore(),
                  );
                }

                return RecipeCard(
                  recipe: recipe,
                  onTap: () => _showRecipeDetail(recipe),
                  isFavorite: true,
                  onFavorite: () => _handleFavoriteToggle(recipe),
                );
              }, childCount: favoritesState.favorites.length),
            ),
          ),
          if (favoritesState.isLoading && favoritesState.favorites.isNotEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFFFF9800)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRatedTab() {
    return Consumer(
      builder: (context, ref, child) {
        final userReviewsState = ref.watch(userReviewsProvider);

        if (userReviewsState.isLoading && userReviewsState.reviews.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF9800)),
          );
        }

        if (userReviewsState.isEmpty) {
          return _buildPlaceholderTab(
            'No rated recipes',
            'Rate recipes after cooking to see them here',
            Icons.star_border,
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await ref
                .read(userReviewsProvider.notifier)
                .loadUserReviews(refresh: true);
          },
          color: const Color(0xFFFF9800),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: userReviewsState.reviews.length +
                (userReviewsState.isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == userReviewsState.reviews.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF9800)),
                  ),
                );
              }

              final reviewItem = userReviewsState.reviews[index];

              // Load more when reaching near the end
              if (index == userReviewsState.reviews.length - 2 &&
                  userReviewsState.hasMore &&
                  !userReviewsState.isLoading) {
                Future.microtask(
                  () => ref.read(userReviewsProvider.notifier).loadMore(),
                );
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBF5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFFE2B8), width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _showRecipeDetail(reviewItem.recipe),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    reviewItem.recipe.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2D2D2D),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDate(reviewItem.createdAt),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF7A7A7A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          StarRating(
                            rating: reviewItem.rating,
                            onRatingChanged: (_) {},
                            isEditable: false,
                            size: 18,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (reviewItem.comment.isNotEmpty)
                        Text(
                          reviewItem.comment,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF4A4A4A),
                            height: 1.5,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderTab(String title, String subtitle, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 100, color: Colors.grey[300]),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // Handle favorite toggle
  Future<void> _handleFavoriteToggle(Recipe recipe) async {
    try {
      await ref.read(recipeListProvider.notifier).toggleFavorite(recipe.id);

      // Reload favorites to sync across all views
      await ref
          .read(favoriteRecipesProvider.notifier)
          .loadFavorites(refresh: true);

      // Sync favorite status in main recipes list
      if (mounted) {
        final favoritesState = ref.read(favoriteRecipesProvider);
        final favoriteIds =
            favoritesState.favorites.map((fav) => fav.recipe.id).toSet();
        ref.read(recipeListProvider.notifier).syncFavoriteStatus(favoriteIds);
      }

      if (mounted) {
        NotificationService.showSuccess(
          context,
          message: recipe.isFavorited
              ? 'Removed from favorites'
              : 'Added to favorites',
        );
      }
    } catch (e) {
      if (mounted) {
        NotificationService.showError(
          context,
          message: 'Failed to update favorite',
        );
      }
    }
  }

  void _showRecipeDetail(Recipe recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RecipeDetailSheet(recipe: recipe),
    );
  }
}

// Filter Bottom Sheet
class _FilterBottomSheet extends ConsumerStatefulWidget {
  final RecipeFilter initialFilter;
  final Function(RecipeFilter) onFilterApplied;

  const _FilterBottomSheet({
    required this.initialFilter,
    required this.onFilterApplied,
  });

  @override
  ConsumerState<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<_FilterBottomSheet> {
  int? _selectedMaxTime;
  final Set<String> _selectedDietTypes = {};
  final Set<String> _selectedIngredients = {};

  final TextEditingController _minCaloriesController = TextEditingController();
  final TextEditingController _maxCaloriesController = TextEditingController();
  final TextEditingController _minProteinController = TextEditingController();
  final TextEditingController _maxProteinController = TextEditingController();
  final TextEditingController _minFatController = TextEditingController();
  final TextEditingController _maxFatController = TextEditingController();
  final TextEditingController _minCarbsController = TextEditingController();
  final TextEditingController _maxCarbsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final filter = widget.initialFilter;
    _selectedMaxTime = filter.maxCookingTime;
    _selectedDietTypes.addAll(filter.dietTypes);
    _selectedIngredients.addAll(filter.ingredientNames);

    _minCaloriesController.text = filter.minCalories?.toStringAsFixed(0) ?? '';
    _maxCaloriesController.text = filter.maxCalories?.toStringAsFixed(0) ?? '';
    _minProteinController.text = filter.minProtein?.toStringAsFixed(0) ?? '';
    _maxProteinController.text = filter.maxProtein?.toStringAsFixed(0) ?? '';
    _minFatController.text = filter.minFat?.toStringAsFixed(0) ?? '';
    _maxFatController.text = filter.maxFat?.toStringAsFixed(0) ?? '';
    _minCarbsController.text =
        filter.minCarbohydrates?.toStringAsFixed(0) ?? '';
    _maxCarbsController.text =
        filter.maxCarbohydrates?.toStringAsFixed(0) ?? '';
  }

  @override
  void dispose() {
    _minCaloriesController.dispose();
    _maxCaloriesController.dispose();
    _minProteinController.dispose();
    _maxProteinController.dispose();
    _minFatController.dispose();
    _maxFatController.dispose();
    _minCarbsController.dispose();
    _maxCarbsController.dispose();
    super.dispose();
  }

  double? _tryParse(TextEditingController controller) {
    final raw = controller.text.trim();
    if (raw.isEmpty) return null;
    return double.tryParse(raw);
  }

  RecipeFilter _buildFilterFromInputs() {
    return RecipeFilter(
      maxCookingTime: _selectedMaxTime,
      minCalories: _tryParse(_minCaloriesController),
      maxCalories: _tryParse(_maxCaloriesController),
      minProtein: _tryParse(_minProteinController),
      maxProtein: _tryParse(_maxProteinController),
      minFat: _tryParse(_minFatController),
      maxFat: _tryParse(_maxFatController),
      minCarbohydrates: _tryParse(_minCarbsController),
      maxCarbohydrates: _tryParse(_maxCarbsController),
      dietTypes: _selectedDietTypes.toList(),
      ingredientNames: _selectedIngredients.toList(),
    );
  }

  Widget _buildRangeInputs(
    String title,
    TextEditingController minController,
    TextEditingController maxController,
    NumericRange? dbRange,
  ) {
    final helper = dbRange != null
        ? 'Available: ${dbRange.min.toStringAsFixed(0)} - ${dbRange.max.toStringAsFixed(0)}'
        : null;

    InputDecoration decoration(String label) {
      return InputDecoration(
        labelText: label,
        isDense: true,
        filled: true,
        fillColor: const Color(0xFFF8F8F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0xFFFF9800), width: 1.5),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          if (helper != null) ...[
            const SizedBox(height: 4),
            Text(
              helper,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: minController,
                  keyboardType: TextInputType.number,
                  decoration: decoration('Min'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: maxController,
                  keyboardType: TextInputType.number,
                  decoration: decoration('Max'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filterOptionsAsync = ref.watch(recipeFilterOptionsProvider);

    final dynamicTimeOptions = filterOptionsAsync.maybeWhen(
      data: (options) {
        final values = options.suggestedCookingTimes.toSet().toList()..sort();
        return [
          {'label': 'All recipes', 'value': null},
          ...values.map(
            (value) => {
              'label': 'Under $value min',
              'value': value,
            },
          ),
        ];
      },
      orElse: () => [
        {'label': 'All recipes', 'value': null},
        {'label': 'Under 15 min', 'value': 15},
        {'label': 'Under 30 min', 'value': 30},
        {'label': 'Under 45 min', 'value': 45},
        {'label': 'Under 60 min', 'value': 60},
      ],
    );

    final dynamicDietOptions = filterOptionsAsync.maybeWhen(
      data: (options) => options.dietTypes,
      orElse: () => <RecipeDietOption>[],
    );

    final dynamicIngredientOptions = filterOptionsAsync.maybeWhen(
      data: (options) => options.ingredients,
      orElse: () => <RecipeIngredientOption>[],
    );

    final nutritionRanges = filterOptionsAsync.maybeWhen(
      data: (options) => options,
      orElse: () => null,
    );

    final totalSelected = _selectedDietTypes.length +
        _selectedIngredients.length +
        (_selectedMaxTime != null ? 1 : 0);

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.tune,
                    color: Color(0xFFFF9800),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Recipe Filters',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Text(
              totalSelected > 0
                  ? '$totalSelected filters selected'
                  : 'Customize recipes for your goals',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cooking time',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: dynamicTimeOptions.map((option) {
                      final selected = _selectedMaxTime == option['value'];
                      return ChoiceChip(
                        label: Text(option['label'] as String),
                        selected: selected,
                        onSelected: (_) {
                          setState(() {
                            _selectedMaxTime = option['value'] as int?;
                          });
                        },
                        selectedColor: const Color(0xFFFFE0B2),
                        labelStyle: TextStyle(
                          color: selected
                              ? const Color(0xFFE65100)
                              : const Color(0xFF4A4A4A),
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w500,
                        ),
                        side: BorderSide(
                          color: selected
                              ? const Color(0xFFFF9800)
                              : Colors.grey.shade300,
                        ),
                        backgroundColor: Colors.white,
                        showCheckmark: false,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildRangeInputs(
              'Calories (kcal)',
              _minCaloriesController,
              _maxCaloriesController,
              nutritionRanges?.calories,
            ),
            const SizedBox(height: 10),
            _buildRangeInputs(
              'Protein (g)',
              _minProteinController,
              _maxProteinController,
              nutritionRanges?.protein,
            ),
            const SizedBox(height: 10),
            _buildRangeInputs(
              'Fat (g)',
              _minFatController,
              _maxFatController,
              nutritionRanges?.fat,
            ),
            const SizedBox(height: 10),
            _buildRangeInputs(
              'Carbohydrates (g)',
              _minCarbsController,
              _maxCarbsController,
              nutritionRanges?.carbohydrates,
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Diet types',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (dynamicDietOptions.isEmpty
                            ? _selectedDietTypes
                                .map((item) => RecipeDietOption(
                                      id: item,
                                      name: item,
                                      recipeCount: 0,
                                    ))
                                .toList()
                            : dynamicDietOptions)
                        .map((diet) {
                      final selected = _selectedDietTypes.contains(diet.name);
                      return FilterChip(
                        label: Text(
                          diet.recipeCount > 0
                              ? '${diet.name} (${diet.recipeCount})'
                              : diet.name,
                        ),
                        selected: selected,
                        onSelected: (value) {
                          setState(() {
                            if (value) {
                              _selectedDietTypes.add(diet.name);
                            } else {
                              _selectedDietTypes.remove(diet.name);
                            }
                          });
                        },
                        selectedColor: const Color(0xFFFFE0B2),
                        checkmarkColor: const Color(0xFFE65100),
                        side: BorderSide(
                          color: selected
                              ? const Color(0xFFFF9800)
                              : Colors.grey.shade300,
                        ),
                        labelStyle: TextStyle(
                          color: selected
                              ? const Color(0xFFE65100)
                              : const Color(0xFF4A4A4A),
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w500,
                        ),
                        showCheckmark: false,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ingredients',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (dynamicIngredientOptions.isEmpty
                            ? _selectedIngredients
                                .map(
                                  (item) => RecipeIngredientOption(
                                    id: item,
                                    name: item,
                                    recipeCount: 0,
                                  ),
                                )
                                .toList()
                            : dynamicIngredientOptions)
                        .map((ingredient) {
                      final selected =
                          _selectedIngredients.contains(ingredient.name);
                      return FilterChip(
                        label: Text(
                          ingredient.recipeCount > 0
                              ? '${ingredient.name} (${ingredient.recipeCount})'
                              : ingredient.name,
                        ),
                        selected: selected,
                        onSelected: (value) {
                          setState(() {
                            if (value) {
                              _selectedIngredients.add(ingredient.name);
                            } else {
                              _selectedIngredients.remove(ingredient.name);
                            }
                          });
                        },
                        selectedColor: const Color(0xFFFFE0B2),
                        checkmarkColor: const Color(0xFFE65100),
                        side: BorderSide(
                          color: selected
                              ? const Color(0xFFFF9800)
                              : Colors.grey.shade300,
                        ),
                        labelStyle: TextStyle(
                          color: selected
                              ? const Color(0xFFE65100)
                              : const Color(0xFF4A4A4A),
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w500,
                        ),
                        showCheckmark: false,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      widget.onFilterApplied(const RecipeFilter());
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      widget.onFilterApplied(_buildFilterFromInputs());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9800),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text(
                      'Apply',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Recipe Detail Bottom Sheet
class _RecipeDetailSheet extends ConsumerStatefulWidget {
  final Recipe recipe;

  const _RecipeDetailSheet({required this.recipe});

  @override
  ConsumerState<_RecipeDetailSheet> createState() => _RecipeDetailSheetState();
}

class _RecipeDetailSheetState extends ConsumerState<_RecipeDetailSheet> {
  late int _selectedServings;

  @override
  void initState() {
    super.initState();
    _selectedServings = widget.recipe.baseServings;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recipeReviewsProvider(widget.recipe.id).notifier).loadReviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    final nutritionAsync = ref.watch(recipeNutritionProvider(widget.recipe.id));
    final recipeListState = ref.watch(recipeListProvider);

    // Get updated recipe with current favorite status from state
    final currentRecipe = recipeListState.recipes.firstWhere(
      (r) => r.id == widget.recipe.id,
      orElse: () => widget.recipe,
    );

    // Load reviews when sheet opens
    ref.listen(recipeReviewsProvider(widget.recipe.id), (previous, next) {});

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Recipe image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        widget.recipe.displayImageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.restaurant,
                              size: 80,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Recipe name
                    Text(
                      widget.recipe.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Cooking time and servings
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 20,
                          color: Color(0xFFFF9800),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.recipe.cookingTimeDisplay,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF666666),
                          ),
                        ),
                        const SizedBox(width: 20),
                        const Icon(
                          Icons.restaurant_menu,
                          size: 20,
                          color: Color(0xFFFF9800),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _showServingsPicker(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFFF9800),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$_selectedServings servings',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFFFF9800),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.edit_outlined,
                                  size: 13,
                                  color: Color(0xFFFF9800),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Description
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.recipe.description,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Nutrition Values Section
                    const Text(
                      'Nutrition Values',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 16),
                    nutritionAsync.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFF9800),
                        ),
                      ),
                      error: (error, stack) => Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Unable to load nutrition data',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      data: (nutrition) => Column(
                        children: [
                          // Nutrition Grid
                          GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _buildNutritionCard(
                                'Calories',
                                '${nutrition.calories.toStringAsFixed(0)} kcal',
                                Icons.local_fire_department,
                                const Color(0xFFFF6B6B),
                              ),
                              _buildNutritionCard(
                                'Protein',
                                '${nutrition.protein.toStringAsFixed(1)}g',
                                Icons.egg,
                                const Color(0xFF51CF66),
                              ),
                              _buildNutritionCard(
                                'Fat',
                                '${nutrition.fat.toStringAsFixed(1)}g',
                                Icons.opacity,
                                const Color(0xFFFFD93D),
                              ),
                              _buildNutritionCard(
                                'Carbs',
                                '${nutrition.carbohydrates.toStringAsFixed(1)}g',
                                Icons.grain,
                                const Color(0xFFFF9800),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Macro Ratio Bar
                          _buildMacroRatioChart(nutrition),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Ingredients Section
                    _buildIngredientsSection(
                      ref,
                      widget.recipe.id,
                      selectedServings: _selectedServings,
                      baseServings: widget.recipe.baseServings,
                    ),
                    const SizedBox(height: 32),

                    // Rating Section
                    _buildRecipeRatingSection(currentRecipe),
                    const SizedBox(height: 32),

                    // Action buttons
                    Column(
                      children: [
                        // Add to Grocery List button
                        _buildAddToGroceryButton(
                          context,
                          ref,
                          widget.recipe,
                          selectedServings: _selectedServings,
                          baseServings: widget.recipe.baseServings,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  try {
                                    await ref
                                        .read(recipeListProvider.notifier)
                                        .toggleFavorite(widget.recipe.id);

                                    // Reload favorites to sync across all views
                                    await ref
                                        .read(favoriteRecipesProvider.notifier)
                                        .loadFavorites(refresh: true);

                                    // Sync favorite status in main recipes list
                                    if (context.mounted) {
                                      final favoritesState = ref.read(
                                        favoriteRecipesProvider,
                                      );
                                      final favoriteIds = favoritesState
                                          .favorites
                                          .map((fav) => fav.recipe.id)
                                          .toSet();
                                      ref
                                          .read(recipeListProvider.notifier)
                                          .syncFavoriteStatus(favoriteIds);
                                      // Get updated recipe to show correct message
                                      final updatedState = ref.read(
                                        recipeListProvider,
                                      );
                                      final updatedRecipe = updatedState.recipes
                                          .firstWhere(
                                              (r) => r.id == widget.recipe.id);

                                      NotificationService.showSuccess(
                                        context,
                                        message: updatedRecipe.isFavorited
                                            ? 'Added to favorites'
                                            : 'Removed from favorites',
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      NotificationService.showError(
                                        context,
                                        message: 'Failed to update favorite',
                                      );
                                    }
                                  }
                                },
                                icon: Icon(
                                  currentRecipe.isFavorited
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: currentRecipe.isFavorited
                                      ? Colors.red
                                      : Colors.black,
                                ),
                                label: Text(
                                  currentRecipe.isFavorited ? 'Saved' : 'Save',
                                  style: const TextStyle(color: Colors.black),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  side: BorderSide(color: Colors.grey[300]!),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // Navigate to cooking mode with recipe ID
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CookingModeScreen(
                                        recipeId: widget.recipe.id,
                                        servings: _selectedServings,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.black,
                                ),
                                label: const Text(
                                  'Cooking Steps',
                                  style: TextStyle(color: Colors.black),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF9800),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showServingsPicker(BuildContext context) {
    const servingOptions = [1, 2, 3, 4, 6, 8];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _ServingsPickerSheet(
        currentServings: _selectedServings,
        options: servingOptions,
        onSelected: (value) {
          setState(() => _selectedServings = value);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  Widget _buildIngredientsSection(
    WidgetRef ref,
    String recipeId, {
    required int selectedServings,
    required int baseServings,
  }) {
    final ingredientsAsync = ref.watch(recipeIngredientsProvider(recipeId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Ingredients',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2D2D),
              ),
            ),
            Text(
              'for $selectedServings serving${selectedServings == 1 ? '' : 's'}',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ingredientsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF9800)),
          ),
          error: (error, stack) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Unable to load ingredients',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          data: (ingredients) {
            if (ingredients.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'No ingredients available',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              );
            }

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey[200]!, width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: ingredients
                    .map(
                      (ingredient) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 8,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _scaledIngredientText(
                                  ingredient,
                                  selectedServings,
                                  baseServings,
                                ),
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF2D2D2D),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  String _scaledIngredientText(
    RecipeIngredient ingredient,
    int selected,
    int base,
  ) {
    final qty = ingredient.quantityAsDouble;
    if (qty == null || base <= 0) return ingredient.displayText;
    final scaled = qty * (selected / base);
    return '${_formatQuantity(scaled)} ${ingredient.unit} ${ingredient.ingredient.name}';
  }

  String _formatQuantity(double value) {
    if (value <= 0) return '0';
    final rounded = double.parse(value.toStringAsFixed(6));
    if (rounded == rounded.truncateToDouble()) {
      return rounded.toInt().toString();
    }
    if (value < 0.1) return value.toStringAsFixed(2);
    final intPart = rounded.floor();
    final frac = rounded - intPart;
    final fractions = {
      0.25: '1/4',
      0.333: '1/3',
      0.5: '1/2',
      0.667: '2/3',
      0.75: '3/4',
    };
    for (final e in fractions.entries) {
      if ((frac - e.key).abs() < 0.02) {
        return intPart == 0 ? e.value : '$intPart ${e.value}';
      }
    }
    final s = value.toStringAsFixed(1);
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  }

  Widget _buildAddToGroceryButton(
    BuildContext context,
    WidgetRef ref,
    Recipe recipe, {
    required int selectedServings,
    required int baseServings,
  }) {
    final ingredientsAsync = ref.watch(recipeIngredientsProvider(recipe.id));
    final groceryListState = ref.watch(groceryListProvider);
    final addingRecipes = ref.watch(addingRecipeProvider);
    final isAdding = addingRecipes.contains(recipe.id);

    final ingredients = ingredientsAsync.asData?.value ?? const [];

    // Only check if THIS RECIPE was already added (by recipeId)
    // Don't check other recipes with same ingredients
    final hasPendingItemsForRecipe = groceryListState.items.any(
      (item) =>
          !item.isPurchased &&
          item.recipeId != null &&
          item.recipeId == recipe.id,
    );

    final isDisabled =
        isAdding || hasPendingItemsForRecipe || ingredients.isEmpty;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isDisabled
            ? null
            : () async {
                if (ingredients.isEmpty) return;

                // Set loading state
                ref
                    .read(addingRecipeProvider.notifier)
                    .update((state) => {...state, recipe.id});

                try {
                  // Convert recipe ingredients to grocery items
                  final groceryItems = ingredients
                      .where((ri) => ri.ingredient.id.isNotEmpty)
                      .map((recipeIngredient) {
                    final quantity =
                        (recipeIngredient.quantityAsDouble ?? 1.0) *
                            (baseServings > 0
                                ? selectedServings / baseServings
                                : 1.0);
                    return GroceryItem(
                      id: '${recipe.id}_${recipeIngredient.ingredient.id}_${DateTime.now().millisecondsSinceEpoch}',
                      ingredientId: recipeIngredient.ingredient.id,
                      name: recipeIngredient.ingredient.name,
                      quantity: quantity,
                      unit: recipeIngredient.unit,
                      recipeId: recipe.id,
                      recipeName: recipe.name,
                    );
                  }).toList();

                  // Add to grocery list
                  await ref
                      .read(groceryListProvider.notifier)
                      .addItems(groceryItems);

                  if (context.mounted) {
                    // Show success notification
                    NotificationService.showSuccess(
                      context,
                      message:
                          'Added ${groceryItems.length} ingredients to grocery list',
                    );
                  }
                } finally {
                  // Reset loading state
                  ref
                      .read(addingRecipeProvider.notifier)
                      .update((state) => {...state}..remove(recipe.id));
                }
              },
        icon: isAdding
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDisabled ? Colors.grey[600]! : Colors.white,
                  ),
                ),
              )
            : const Icon(Icons.shopping_bag_outlined, color: Colors.white),
        label: Text(
          isAdding
              ? 'Adding...'
              : hasPendingItemsForRecipe
                  ? 'Already added (pending)'
                  : 'Add to Grocery List',
          style: TextStyle(
            color: isDisabled ? Colors.grey[600] : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF51CF66),
          disabledBackgroundColor: const Color(0xFF2F6B3C),
          disabledForegroundColor: Colors.grey[600],
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildRecipeRatingSection(Recipe recipe) {
    return Consumer(
      builder: (context, ref, child) {
        final reviewsState = ref.watch(recipeReviewsProvider(recipe.id));
        final userReviewAsync = ref.watch(userRecipeReviewProvider(recipe.id));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (reviewsState.stats != null)
              Column(
                children: [
                  RatingStatsWidget(stats: reviewsState.stats!),
                  const SizedBox(height: 24),
                ],
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Rating',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 12),
                userReviewAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(color: Color(0xFFFF9800)),
                  ),
                  error: (error, stack) => ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => RatingDialog(recipeId: recipe.id),
                      );
                    },
                    icon: const Icon(Icons.star, color: Colors.amber),
                    label: const Text(
                      'Rate Recipe',
                      style: TextStyle(color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9800),
                      foregroundColor: Colors.black,
                    ),
                  ),
                  data: (userReview) {
                    if (userReview == null) {
                      return ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) =>
                                RatingDialog(recipeId: recipe.id),
                          );
                        },
                        icon: const Icon(Icons.star, color: Colors.amber),
                        label: const Text(
                          'Rate Recipe',
                          style: TextStyle(color: Colors.black),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9800),
                          foregroundColor: Colors.black,
                        ),
                      );
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBF5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFFFE2B8),
                          width: 1,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                StarRating(
                                  rating: userReview.rating,
                                  onRatingChanged: (_) {},
                                  isEditable: false,
                                  size: 24,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => RatingDialog(
                                        recipeId: recipe.id,
                                        existingReview: userReview,
                                      ),
                                    );
                                  },
                                  child: const Icon(
                                    Icons.edit,
                                    color: Color(0xFFFF9800),
                                  ),
                                ),
                              ],
                            ),
                            if (userReview.comment.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              const Divider(
                                height: 1,
                                color: Color(0xFFFFE2B8),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                userReview.comment,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF4A4A4A),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Reviews',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 300,
              child: RecipeReviewsList(recipeId: recipe.id),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMacroRatioChart(RecipeNutrition nutrition) {
    // Calculate macro percentages
    final proteinCals = nutrition.protein * 4;
    final fatCals = nutrition.fat * 9;
    final carbsCals = nutrition.carbohydrates * 4;
    final totalMacroCals = proteinCals + fatCals + carbsCals;

    final proteinPercent =
        totalMacroCals > 0 ? (proteinCals / totalMacroCals) * 100 : 0;
    final fatPercent =
        totalMacroCals > 0 ? (fatCals / totalMacroCals) * 100 : 0;
    final carbsPercent =
        totalMacroCals > 0 ? (carbsCals / totalMacroCals) * 100 : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Macro bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Row(
            children: [
              Expanded(
                flex: proteinPercent.toInt(),
                child: Container(height: 16, color: const Color(0xFF51CF66)),
              ),
              Expanded(
                flex: fatPercent.toInt(),
                child: Container(height: 16, color: const Color(0xFFFFD93D)),
              ),
              Expanded(
                flex: carbsPercent.toInt(),
                child: Container(height: 16, color: const Color(0xFFFF9800)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMacroLegend(
              'Protein',
              '${proteinPercent.toStringAsFixed(0)}%',
              const Color(0xFF51CF66),
            ),
            _buildMacroLegend(
              'Fat',
              '${fatPercent.toStringAsFixed(0)}%',
              const Color(0xFFFFD93D),
            ),
            _buildMacroLegend(
              'Carbs',
              '${carbsPercent.toStringAsFixed(0)}%',
              const Color(0xFFFF9800),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMacroLegend(String label, String percentage, Color color) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        Text(
          percentage,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
          ),
        ),
      ],
    );
  }
}

class _ServingsPickerSheet extends StatelessWidget {
  final int currentServings;
  final List<int> options;
  final ValueChanged<int> onSelected;

  const _ServingsPickerSheet({
    required this.currentServings,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Adjust Servings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Text(
            'Ingredient amounts will scale automatically',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: options.map((option) {
              final isSelected = option == currentServings;
              return GestureDetector(
                onTap: () => onSelected(option),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFF9800) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFF9800)
                          : Colors.grey[300]!,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    '$option',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected ? Colors.white : const Color(0xFF2D2D2D),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
