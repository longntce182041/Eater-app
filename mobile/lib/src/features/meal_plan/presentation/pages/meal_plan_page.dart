import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/meal_plan_provider.dart';
import '../../domain/meal_plan_models.dart';

class MealPlanPage extends ConsumerStatefulWidget {
  const MealPlanPage({super.key});

  @override
  ConsumerState<MealPlanPage> createState() => _MealPlanPageState();
}

class _MealPlanPageState extends ConsumerState<MealPlanPage>
    with WidgetsBindingObserver {
  int _selectedDays = 7;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mealPlanNotifierProvider.notifier).loadLatestMealPlan();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Reload meal plan when app resumes from background
    if (state == AppLifecycleState.resumed) {
      ref.read(mealPlanNotifierProvider.notifier).loadLatestMealPlan();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mealPlanNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F1E8),
        elevation: 0,
        title: const Text(
          'Meal Plan',
          style: TextStyle(
            color: Color(0xFF2D2D2D),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (state.result != null)
            IconButton(
              onPressed: state.isLoading ? null : () => _confirmDelete(context),
              icon: const Icon(Icons.delete_outline),
              color: const Color(0xFFD32F2F),
              tooltip: 'Delete meal plans',
            ),
        ],
      ),
      body: state.isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Color(0xFFFF9800)),
                  const SizedBox(height: 16),
                  const Text('Loading your meal plan...'),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () => ref
                  .read(mealPlanNotifierProvider.notifier)
                  .loadLatestMealPlan(),
              color: const Color(0xFFFF9800),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Get balanced meal schedule for your goals and tastes',
                      style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
                    ),
                    const SizedBox(height: 24),
                    _buildHeroCard(),
                    const SizedBox(height: 24),
                    _buildHighlights(),
                    const SizedBox(height: 24),
                    if (state.error != null) _buildError(state.error!),
                    if (state.result != null) ...[
                      _buildSummary(state.result!),
                      const SizedBox(height: 16),
                      Container(
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
                        child: _buildItems(state.result!),
                      ),
                    ],
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: SizedBox(
          height: 56,
          child: state.result != null
              ? Row(
                  children: [
                    // Optimize All button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: state.isLoading
                            ? null
                            : () => _optimizeAllMeals(
                                context,
                                state.result!.mealPlan.id,
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.auto_fix_high),
                        label: const Text(
                          'Optimize',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Regenerate button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: state.isLoading ? null : _onGeneratePressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9800),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.refresh),
                        label: const Text(
                          'Regenerate',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : ElevatedButton.icon(
                  onPressed: state.isLoading ? null : _onGeneratePressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'Create meal plan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.calendar_today,
              size: 42,
              color: Color(0xFFFF9800),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Personalized plan generated by AI based on your profile.',
              style: TextStyle(fontSize: 15, color: Color(0xFF2D2D2D)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlights() {
    return Column(
      children: const [
        _HighlightRow(
          icon: Icons.restaurant,
          text: 'Meals for breakfast, lunch, and dinner',
        ),
        SizedBox(height: 12),
        _HighlightRow(
          icon: Icons.star_border,
          text: 'Tailored to your goals and preferences',
        ),
        SizedBox(height: 12),
        _HighlightRow(
          icon: Icons.pie_chart_outline,
          text: 'Balanced proteins, fats, carbs and fiber',
        ),
      ],
    );
  }

  Widget _buildError(String message) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEF9A9A)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFD32F2F)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFFD32F2F)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(MealPlanGenerationResult result) {
    final summary = result.summary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Meal plan summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Days: ${result.mealPlan.days}',
            style: const TextStyle(color: Color(0xFF2D2D2D)),
          ),
          Text(
            'Total meals: ${summary?.totalMeals ?? result.items.length}',
            style: const TextStyle(color: Color(0xFF2D2D2D)),
          ),
          if (summary != null)
            Text(
              'Avg calories/day: ${summary.avgCaloriesPerDay.toStringAsFixed(0)}',
              style: const TextStyle(color: Color(0xFF2D2D2D)),
            ),
        ],
      ),
    );
  }

  Widget _buildItems(MealPlanGenerationResult result) {
    if (result.items.isEmpty) {
      return const SizedBox.shrink();
    }

    // Group items by dayIndex and sort
    final Map<int, List<MealPlanItemModel>> itemsByDay = {};
    for (final item in result.items) {
      itemsByDay.putIfAbsent(item.dayIndex, () => []).add(item);
    }

    // Sort by day index
    final sortedDays = itemsByDay.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.restaurant, color: Color(0xFFFF9800), size: 24),
              const SizedBox(width: 8),
              const Text(
                'Meals',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${sortedDays.length} days',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFF9800),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
        ...sortedDays.asMap().entries.map((dayEntry) {
          final dayIndex = dayEntry.value.key;
          final dayItems = dayEntry.value.value;
          final isLastDay = dayEntry.key == sortedDays.length - 1;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                color: const Color(0xFFFFF3E0),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9800),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${dayIndex + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Day ${dayIndex + 1}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFF9800),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${dayItems.length} meals',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
              ),
              // Day meals
              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    ...dayItems.asMap().entries.map((mealEntry) {
                      final item = mealEntry.value;
                      final isLastItem = mealEntry.key == dayItems.length - 1;

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: _buildMealItem(item),
                          ),
                          if (!isLastItem)
                            const Divider(
                              height: 1,
                              thickness: 0.5,
                              indent: 16,
                              endIndent: 16,
                            ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              if (!isLastDay)
                const SizedBox(height: 8)
              else
                const SizedBox(height: 16),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildMealItem(MealPlanItemModel item) {
    return Column(
      children: [
        Row(
          children: [
            // Meal type badge - consistent width for alignment
            Container(
              width: 90,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: _getMealTypeColor(item.mealType).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getMealTypeColor(
                    item.mealType,
                  ).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  _titleCase(item.mealType),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _getMealTypeColor(item.mealType),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Recipe image - larger
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: item.recipeImageUrl?.isNotEmpty == true
                  ? Image.network(
                      item.recipeImageUrl!,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFFFF9800),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.restaurant,
                            color: Colors.grey,
                            size: 28,
                          ),
                        );
                      },
                    )
                  : Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.restaurant,
                        color: Colors.grey,
                        size: 28,
                      ),
                    ),
            ),
            const SizedBox(width: 14),
            // Meal info - expanded
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.recipeName?.isNotEmpty == true
                        ? item.recipeName!
                        : 'Recipe',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFF2D2D2D),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.calories.toStringAsFixed(0)} kcal • ${item.servings.toStringAsFixed(2)} serving${item.servings.toInt() != 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (item.protein > 0 ||
                      item.carbohydrates > 0 ||
                      item.fat > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'P: ${item.protein.toStringAsFixed(1)}g | C: ${item.carbohydrates.toStringAsFixed(1)}g | F: ${item.fat.toStringAsFixed(1)}g',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        // NEW: Action buttons for meal optimization
        const SizedBox(height: 8),
        _buildMealItemActions(item),
      ],
    );
  }

  /// Build action buttons for meal item (rate, replace)
  Widget _buildMealItemActions(MealPlanItemModel item) {
    final mealPlanId = ref.read(mealPlanNotifierProvider).result?.mealPlan.id;
    if (mealPlanId == null) return const SizedBox.shrink();

    return Row(
      children: [
        // Rating button
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFFE0B2), width: 1),
          ),
          child: PopupMenuButton<int>(
            onSelected: (rating) {
              ref
                  .read(mealPlanNotifierProvider.notifier)
                  .rateMeal(mealPlanId, item.id, rating);
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 1,
                  child: Row(
                    children: [
                      _buildStarRating(1),
                      const SizedBox(width: 8),
                      const Text('Poor'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 2,
                  child: Row(
                    children: [
                      _buildStarRating(2),
                      const SizedBox(width: 8),
                      const Text('Fair'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 3,
                  child: Row(
                    children: [
                      _buildStarRating(3),
                      const SizedBox(width: 8),
                      const Text('Good'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 4,
                  child: Row(
                    children: [
                      _buildStarRating(4),
                      const SizedBox(width: 8),
                      const Text('Very Good'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 5,
                  child: Row(
                    children: [
                      _buildStarRating(5),
                      const SizedBox(width: 8),
                      const Text('Excellent'),
                    ],
                  ),
                ),
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.userRating != null ? Icons.star : Icons.star_outline,
                    size: 18,
                    color: const Color(0xFFFF9800),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.userRating != null ? '${item.userRating}/5' : 'Rate',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF9800),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Replace meal button (disabled if locked)
        if (!item.isLocked)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFE0B2), width: 1),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () =>
                      _showReplacementDialog(context, mealPlanId, item),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.swap_horiz,
                          size: 18,
                          color: Color(0xFFFF9800),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Replace',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFF9800),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Build star rating widget
  Widget _buildStarRating(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_outline,
          size: 16,
          color: const Color(0xFFFF9800),
        );
      }),
    );
  }

  /// Show replacement suggestions dialog
  void _showReplacementDialog(
    BuildContext context,
    String planId,
    MealPlanItemModel currentItem,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Replace meal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Current: ${currentItem.recipeName}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Reason dropdown
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Why are you replacing this?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'dont_like_taste',
                          child: Text('Don\'t like the taste'),
                        ),
                        DropdownMenuItem(
                          value: 'allergies',
                          child: Text('Have allergies'),
                        ),
                        DropdownMenuItem(
                          value: 'prep_difficulty',
                          child: Text('Too difficult to prepare'),
                        ),
                        DropdownMenuItem(
                          value: 'ingredients_unavailable',
                          child: Text('Ingredients not available'),
                        ),
                      ],
                      onChanged: (_) {},
                      value: 'dont_like_taste',
                    ),
                    const SizedBox(height: 16),
                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF9800),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            // In a real app, fetch suggestions and show them
                            // For now, we'll show a simple message
                            Navigator.pop(dialogContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Fetching replacement suggestions...',
                                ),
                              ),
                            );
                          },
                          child: const Text('Get suggestions'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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

  Future<void> _onGeneratePressed() async {
    final days = await _pickDays(context, _selectedDays);
    if (days == null) return;
    setState(() => _selectedDays = days);
    await ref
        .read(mealPlanNotifierProvider.notifier)
        .generateMealPlan(days: days);
  }

  Future<void> _optimizeAllMeals(
    BuildContext context,
    String mealPlanId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Optimize meal plan?'),
        content: const Text(
          'This will replace low-rated meals and improve variety while maintaining your calorie targets.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF4CAF50),
            ),
            child: const Text('Optimize'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref
        .read(mealPlanNotifierProvider.notifier)
        .optimizeMealPlan(mealPlanId);

    if (!mounted) return;

    final state = ref.read(mealPlanNotifierProvider);
    if (state.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${state.error}')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meal plan optimized successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete meal plans?'),
          content: const Text(
            'This will remove all meal plans and their meals. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFD32F2F),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    await ref.read(mealPlanNotifierProvider.notifier).deleteAllMealPlans();
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('All meal plans deleted')));
  }

  Future<int?> _pickDays(BuildContext context, int current) async {
    int tempDays = current;
    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select number of days',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: tempDays,
                    items: List.generate(7, (index) => index + 1)
                        .map(
                          (day) => DropdownMenuItem(
                            value: day,
                            child: Text('$day days'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setSheetState(() => tempDays = value);
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(tempDays),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9800),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Generate meal plan'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _titleCase(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }
}

class _HighlightRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HighlightRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFF9800)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
        ),
      ],
    );
  }
}
