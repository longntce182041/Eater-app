import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/recipe_models.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_widgets.dart';

class RecipesPage extends ConsumerStatefulWidget {
  const RecipesPage({super.key});

  @override
  ConsumerState<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends ConsumerState<RecipesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load recipes when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recipeListProvider.notifier).loadRecipes();
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _FilterBottomSheet(
          onFilterApplied: (int? maxTime) {
            ref.read(recipeListProvider.notifier).filterByTime(maxTime);
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
                        color: const Color(0xFF2D3748),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.tune, color: Colors.white),
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

          // Favorites tab - placeholder
          _buildPlaceholderTab(
            'No favorites yet',
            'Tap the heart icon on recipes to save them here',
            Icons.favorite_border,
          ),

          // Rated tab - placeholder
          _buildPlaceholderTab(
            'No rated recipes',
            'Rate recipes after cooking to see them here',
            Icons.star_border,
          ),
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
                  onFavorite: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added ${recipe.name} to favorites'),
                        duration: const Duration(seconds: 2),
                        backgroundColor: const Color(0xFFFF9800),
                      ),
                    );
                  },
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
class _FilterBottomSheet extends StatefulWidget {
  final Function(int?) onFilterApplied;

  const _FilterBottomSheet({required this.onFilterApplied});

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  int? _selectedMaxTime;

  final List<Map<String, dynamic>> _timeOptions = [
    {'label': 'All recipes', 'value': null},
    {'label': 'Under 15 min', 'value': 15},
    {'label': 'Under 30 min', 'value': 30},
    {'label': 'Under 45 min', 'value': 45},
    {'label': 'Under 1 hour', 'value': 60},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter by cooking time',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...(_timeOptions.map((option) {
            return RadioListTile<int?>(
              title: Text(option['label'] as String),
              value: option['value'] as int?,
              groupValue: _selectedMaxTime,
              activeColor: const Color(0xFFFF9800),
              onChanged: (value) {
                setState(() {
                  _selectedMaxTime = value;
                });
              },
            );
          })),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onFilterApplied(_selectedMaxTime);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9800),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Apply Filter',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Recipe Detail Bottom Sheet
class _RecipeDetailSheet extends StatelessWidget {
  final Recipe recipe;

  const _RecipeDetailSheet({required this.recipe});

  @override
  Widget build(BuildContext context) {
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
                        recipe.displayImageUrl,
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
                      recipe.name,
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
                          recipe.cookingTimeDisplay,
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
                        Text(
                          '${recipe.baseServings} servings',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF666666),
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
                      recipe.description,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // TODO: Add to favorites
                            },
                            icon: const Icon(Icons.favorite_border),
                            label: const Text('Save'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
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
                              // TODO: Start cooking
                            },
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Start Cooking'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF9800),
                              padding: const EdgeInsets.symmetric(vertical: 14),
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
              ),
            ],
          ),
        );
      },
    );
  }
}
