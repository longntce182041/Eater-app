import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/notification_service.dart';
import '../../../home/data/recipe_api_client.dart';
import '../../../home/domain/recipe_models.dart';

class MealPlanPreviewPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> previewData;
  final Function(Map<String, dynamic>) onSaveMealPlan;

  const MealPlanPreviewPage({
    super.key,
    required this.previewData,
    required this.onSaveMealPlan,
  });

  @override
  ConsumerState<MealPlanPreviewPage> createState() =>
      _MealPlanPreviewPageState();
}

class _MealPlanPreviewPageState extends ConsumerState<MealPlanPreviewPage> {
  late Map<String, dynamic> modifiedMeals; // Track replaced meals
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    // Copy all meals from original data - can be modified via replacement
    modifiedMeals = {};
    final mealsByDay =
        (widget.previewData['preview']['mealsByDay'] as List?) ?? [];
    for (var day in mealsByDay) {
      final meals = (day['meals'] as List?) ?? [];
      for (var meal in meals) {
        final mealId = meal['id'] as String?;
        if (mealId != null) {
          modifiedMeals[mealId] = Map<String, dynamic>.from(meal);
        }
      }
    }
  }

  void _replaceMeal(String mealId, String mealType) async {
    // Show dialog to select replacement recipe
    final selectedRecipe = await showDialog<Recipe>(
      context: context,
      builder: (context) => _RecipeSelectionDialog(
        mealType: mealType,
        recipeApiClient: ref.read(recipeApiClientProvider),
      ),
    );

    if (selectedRecipe != null) {
      setState(() {
        // Update meal with new recipe data
        final currentMeal = modifiedMeals[mealId]!;
        modifiedMeals[mealId] = {
          ...currentMeal,
          'name': selectedRecipe.name,
          'recipeId': selectedRecipe.id,
          // Note: Backend will fetch actual nutrition data when saving
          'calories': 0.0, // Placeholder - will be updated by backend
          'protein': 0.0,
          'carbs': 0.0,
          'fat': 0.0,
          'servings': 1.0,
          'isReplaced': true, // Mark as replaced for UI feedback
        };
      });

      if (mounted) {
        NotificationService.showSuccess(
          context,
          message: 'Meal replaced with ${selectedRecipe.name}',
        );
      }
    }
  }

  void _saveMealPlan() {
    // Return modified meals data
    widget.onSaveMealPlan(modifiedMeals);
  }

  @override
  Widget build(BuildContext context) {
    final preview = widget.previewData['preview'] as Map<String, dynamic>;
    final mealsByDay = (preview['mealsByDay'] as List?) ?? [];

    // Calculate total calories from modified meals
    double totalCalories = 0;
    for (var meal in modifiedMeals.values) {
      totalCalories += (meal['calories'] as num?)?.toDouble() ?? 0;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F1E8),
        elevation: 0,
        title: const Text(
          'Review & Customize Your Meal Plan',
          style: TextStyle(
            color: Color(0xFF2D2D2D),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFE0B2)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, color: Color(0xFFFF9800), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tap "Replace" on any meal to choose a different recipe',
                      style: TextStyle(fontSize: 13, color: Color(0xFF2D2D2D)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Meal Plan Summary',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryItem(
                        label: 'Days',
                        value: '${mealsByDay.length}',
                        icon: Icons.calendar_today,
                      ),
                      _buildSummaryItem(
                        label: 'Total Meals',
                        value: '${modifiedMeals.length}',
                        icon: Icons.restaurant,
                      ),
                      _buildSummaryItem(
                        label: 'Total Calories',
                        value: totalCalories.toStringAsFixed(0),
                        icon: Icons.local_fire_department,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Daily Meals
            const Text(
              'Daily Meals',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 12),
            ...mealsByDay.asMap().entries.map((dayEntry) {
              final dayIndex = dayEntry.key;
              final day = dayEntry.value as Map<String, dynamic>;
              final dayNumber = (day['dayNumber'] as num?)?.toInt() ?? 1;
              final meals = (day['meals'] as List?) ?? [];

              // Calculate day calories from modified meals
              double dayCalories = 0;
              for (var meal in meals) {
                final mealId = (meal as Map<String, dynamic>)['id'] as String?;
                if (mealId != null && modifiedMeals.containsKey(mealId)) {
                  dayCalories +=
                      (modifiedMeals[mealId]!['calories'] as num?)
                          ?.toDouble() ??
                      0;
                }
              }

              return _buildDayCard(
                dayNumber: dayNumber,
                dayIndex: dayIndex,
                meals: meals,
                dayCalories: dayCalories,
              );
            }).toList(),

            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: const BorderSide(color: Color(0xFFFF9800)),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Color(0xFFFF9800),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isSaving ? null : _saveMealPlan,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFFFF9800),
                  disabledBackgroundColor: Colors.grey[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: isSaving
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(
                  isSaving ? 'Saving...' : 'Save Plan',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFFF9800), size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
        ),
      ],
    );
  }

  Widget _buildDayCard({
    required int dayNumber,
    required int dayIndex,
    required List<dynamic> meals,
    required double dayCalories,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Day header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Day $dayNumber',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      size: 16,
                      color: Colors.orange[700],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${dayCalories.toStringAsFixed(0)} cal',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Meals list
          ...meals.map((meal) {
            final mealMap = meal as Map<String, dynamic>;
            final mealId = mealMap['id'] as String? ?? '';

            // Get meal data from modifiedMeals (may have been replaced)
            final mealData = modifiedMeals[mealId] ?? mealMap;
            final mealType = mealData['mealType'] as String? ?? 'Meal';
            final name = mealData['name'] as String? ?? 'Unknown';
            final calories = (mealData['calories'] as num?)?.toDouble() ?? 0;
            final protein = (mealData['protein'] as num?)?.toDouble() ?? 0;
            final carbs = (mealData['carbs'] as num?)?.toDouble() ?? 0;
            final fat = (mealData['fat'] as num?)?.toDouble() ?? 0;
            final isReplaced = mealData['isReplaced'] == true;

            return _buildMealItem(
              mealId: mealId,
              mealType: mealType,
              name: name,
              calories: calories,
              protein: protein,
              carbs: carbs,
              fat: fat,
              isReplaced: isReplaced,
              onReplace: () => _replaceMeal(mealId, mealType),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMealItem({
    required String mealId,
    required String mealType,
    required String name,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    required bool isReplaced,
    required VoidCallback onReplace,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 0.5)),
        color: isReplaced ? const Color(0xFFF0F9FF) : null,
      ),
      child: Row(
        children: [
          // Meal type badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getMealTypeColor(mealType).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _getMealTypeColor(mealType).withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              mealType.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: _getMealTypeColor(mealType),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Meal info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (isReplaced) ...[
                      Icon(Icons.swap_horiz, size: 14, color: Colors.blue[700]),
                      const SizedBox(width: 4),
                    ],
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D2D2D),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${calories.toStringAsFixed(0)}kcal • P:${protein.toStringAsFixed(0)}g C:${carbs.toStringAsFixed(0)}g F:${fat.toStringAsFixed(0)}g',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Replace button
          TextButton.icon(
            onPressed: onReplace,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              backgroundColor: const Color(0xFFFFF3E0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(
              Icons.swap_horiz,
              size: 16,
              color: Color(0xFFFF9800),
            ),
            label: const Text(
              'Replace',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFF9800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getMealTypeColor(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return const Color(0xFFFFC107);
      case 'lunch':
        return const Color(0xFFFF9800);
      case 'dinner':
        return const Color(0xFF2196F3);
      case 'snack':
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}

// Dialog to select replacement recipe
class _RecipeSelectionDialog extends StatefulWidget {
  final String mealType;
  final RecipeApiClient recipeApiClient;

  const _RecipeSelectionDialog({
    required this.mealType,
    required this.recipeApiClient,
  });

  @override
  State<_RecipeSelectionDialog> createState() => _RecipeSelectionDialogState();
}

class _RecipeSelectionDialogState extends State<_RecipeSelectionDialog> {
  List<Recipe> recipes = [];
  bool isLoading = true;
  String? error;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final response = await widget.recipeApiClient.getAllRecipes(
        page: 1,
        limit: 50,
        status: 'published',
      );

      setState(() {
        recipes = response.recipes;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load recipes: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _searchRecipes(String query) async {
    if (query.isEmpty) {
      _loadRecipes();
      return;
    }

    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final response = await widget.recipeApiClient.searchRecipes(
        keyword: query,
        page: 1,
        limit: 50,
        status: 'published',
      );

      setState(() {
        recipes = response.recipes;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to search recipes: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Select ${widget.mealType} Recipe',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search recipes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                searchQuery = value;
                _searchRecipes(value);
              },
            ),
            const SizedBox(height: 16),

            // Recipes list
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadRecipes,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : recipes.isEmpty
                  ? const Center(child: Text('No recipes found'))
                  : ListView.builder(
                      itemCount: recipes.length,
                      itemBuilder: (context, index) {
                        final recipe = recipes[index];
                        return _buildRecipeItem(recipe);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeItem(Recipe recipe) {
    return InkWell(
      onTap: () => Navigator.pop(context, recipe),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Recipe image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty
                  ? Image.network(
                      recipe.imageUrl!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          child: const Icon(Icons.restaurant, size: 30),
                        );
                      },
                    )
                  : Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[300],
                      child: const Icon(Icons.restaurant, size: 30),
                    ),
            ),
            const SizedBox(width: 12),

            // Recipe info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2D2D),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recipe.cookingTimeDisplay,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF999999),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    recipe.description,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF999999),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF999999),
            ),
          ],
        ),
      ),
    );
  }
}
