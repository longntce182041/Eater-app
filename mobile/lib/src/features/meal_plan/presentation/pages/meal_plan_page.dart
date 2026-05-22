import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/meal_plan_provider.dart';
import '../providers/recipe_detail_provider.dart';
import '../../domain/meal_plan_models.dart';
import '../../data/meal_plan_to_grocery_converter.dart';
import '../widgets/macro_distribution_donut.dart';
import '../widgets/detailed_macro_modal.dart';
import '../pages/meal_plan_preview_page.dart';
import '../../../../core/utils/notification_service.dart';
import '../../../../shared/providers/auth_token_provider.dart';
import '../../../nutrition/domain/entities/meal_log.dart';
import '../../../nutrition/presentation/providers/meal_log_provider.dart';
import '../../../nutrition/presentation/providers/navigation_provider.dart';
import '../../../nutrition/data/providers/meal_log_service_provider.dart';
import '../../../home/data/recipe_ingredients_api.dart';
import '../../../grocery/presentation/providers/grocery_list_provider.dart';

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
      // Don't initialize meal logs here - local state starts empty
      // As user checks meals, they get added to local state
      // meal_logging_page will initialize when needed
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
                      _buildSummaryWithMacros(state.result!),
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

  Widget _buildSummaryWithMacros(MealPlanGenerationResult result) {
    return Column(
      children: [
        _buildSummary(result),
        const SizedBox(height: 16),
        _buildMacroSummaryCard(result),
      ],
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
          const SizedBox(height: 12),
          Text(
            'Days: ${result.mealPlan.days}',
            style: const TextStyle(color: Color(0xFF2D2D2D), fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            'Total meals: ${summary?.totalMeals ?? result.items.length}',
            style: const TextStyle(color: Color(0xFF2D2D2D), fontSize: 13),
          ),
          const SizedBox(height: 8),
          if (summary != null)
            Text(
              'Avg: ${summary.avgCaloriesPerDay.toStringAsFixed(0)} kcal/day',
              style: const TextStyle(color: Color(0xFF2D2D2D), fontSize: 13),
            ),
        ],
      ),
    );
  }

  Widget _buildMacroSummaryCard(MealPlanGenerationResult result) {
    final dailyMacros = _buildDailyMacros(result);
    if (dailyMacros.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'No macro data yet',
            style: TextStyle(color: Color(0xFF999999)),
          ),
        ),
      );
    }

    // Show aggregate macro distribution across all days.
    final totalProtein = dailyMacros.fold<double>(
      0,
      (sum, day) => sum + day.protein,
    );
    final totalCarbohydrates = dailyMacros.fold<double>(
      0,
      (sum, day) => sum + day.carbohydrates,
    );
    final totalFat = dailyMacros.fold<double>(
      0,
      (sum, day) => sum + day.fat,
    );

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
            'Macro distribution',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 12),
          MacroDistributionDonut(
            protein: totalProtein,
            carbohydrates: totalCarbohydrates,
            fat: totalFat,
            onViewAll: () {
              _showDetailedMacroModal(dailyMacros, result);
            },
          ),
        ],
      ),
    );
  }

  Future<Map<int, List<DailyMicronutrient>>> _buildDailyMicronutrients(
    MealPlanGenerationResult result,
    List<_DailyMacro> dailyMacros,
  ) async {
    final recipeIds = result.items
        .map((item) => item.recipeId)
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    if (recipeIds.isEmpty || dailyMacros.isEmpty) {
      return {};
    }

    final recipeDetailService = ref.read(recipeDetailServiceProvider);
    final recipeMicronutrientCache = <String, List<DailyMicronutrient>>{};

    await Future.wait(recipeIds.map((recipeId) async {
      try {
        final detail = await recipeDetailService.getRecipeFullDetails(recipeId);
        final micronutrients =
            (detail['micronutrients'] as List<dynamic>? ?? [])
                .whereType<Map<String, dynamic>>()
                .map((item) {
                  final micronutrient =
                      item['micronutrientId'] as Map<String, dynamic>? ?? {};

                  return DailyMicronutrient(
                    name: micronutrient['name']?.toString() ?? 'Nutrient',
                    unit: micronutrient['unit']?.toString() ?? '',
                    amount: (item['amount'] as num?)?.toDouble() ?? 0,
                  );
                })
                .where((item) => item.amount > 0)
                .toList();

        recipeMicronutrientCache[recipeId] = micronutrients;
      } catch (_) {
        recipeMicronutrientCache[recipeId] = const [];
      }
    }));

    final dayTotals = <int, Map<String, DailyMicronutrient>>{};

    for (final mealItem in result.items) {
      final recipeId = mealItem.recipeId;
      if (recipeId == null || recipeId.isEmpty) continue;

      final dayIndex = mealItem.dayIndex;
      if (dayIndex < 0 || dayIndex >= dailyMacros.length) continue;

      final mealMicronutrients = recipeMicronutrientCache[recipeId] ?? const [];
      if (mealMicronutrients.isEmpty) continue;

      final servingMultiplier =
          mealItem.servings > 0 ? mealItem.servings.toDouble() : 1.0;
      final dayMap = dayTotals.putIfAbsent(dayIndex, () => {});

      for (final micro in mealMicronutrients) {
        final key = '${micro.name}|${micro.unit}';
        final existing = dayMap[key];

        if (existing == null) {
          dayMap[key] = DailyMicronutrient(
            name: micro.name,
            unit: micro.unit,
            amount: micro.amount * servingMultiplier,
          );
          continue;
        }

        dayMap[key] = existing.copyWith(
          amount: existing.amount + (micro.amount * servingMultiplier),
        );
      }
    }

    final output = <int, List<DailyMicronutrient>>{};
    for (final entry in dayTotals.entries) {
      final micros = entry.value.values.toList()
        ..sort((a, b) => b.amount.compareTo(a.amount));
      output[entry.key] = micros;
    }

    return output;
  }

  Future<void> _showDetailedMacroModal(
    List<_DailyMacro> dailyMacros,
    MealPlanGenerationResult result,
  ) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF9800)),
      ),
    );

    final dailyMicronutrientMap =
        await _buildDailyMicronutrients(result, dailyMacros);

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    // Convert internal _DailyMacro to public DailyMacro
    final dailyMacroList = dailyMacros
        .map(
          (m) => DailyMacro(
            dayIndex: m.dayIndex,
            protein: m.protein,
            carbohydrates: m.carbohydrates,
            fat: m.fat,
            micronutrients: dailyMicronutrientMap[m.dayIndex] ?? const [],
          ),
        )
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: DetailedMacroBottomSheet(dailyMacros: dailyMacroList),
              ),
            );
          },
        );
      },
    );
  }

  List<_DailyMacro> _buildDailyMacros(MealPlanGenerationResult result) {
    if (result.items.isEmpty) return [];

    final daysFromItems = result.items
            .map((item) => item.dayIndex)
            .fold<int>(0, (max, value) => value > max ? value : max) +
        1;
    final totalDays = result.mealPlan.days > daysFromItems
        ? result.mealPlan.days
        : daysFromItems;

    final macros = List.generate(
      totalDays,
      (index) => _DailyMacro(dayIndex: index),
    );

    for (final item in result.items) {
      if (item.dayIndex < 0 || item.dayIndex >= macros.length) continue;
      final target = macros[item.dayIndex];
      target.protein += item.protein;
      target.carbohydrates += item.carbohydrates;
      target.fat += item.fat;
    }

    return macros;
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

    // Keep all days visible; completed days are dimmed instead of being hidden.
    final visibleDays = sortedDays;

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
                  '${visibleDays.length} days remaining',
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
        ...visibleDays.asMap().entries.map((dayEntry) {
          final dayIndex = dayEntry.value.key;
          final dayItems = dayEntry.value.value;
          final isLastDay = dayEntry.key == visibleDays.length - 1;
          final allMealsEaten = dayItems.every((item) => item.isEaten);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                color: allMealsEaten
                    ? const Color(0xFFE8F5E9) // Light green for completed
                    : const Color(0xFFFFF3E0), // Light orange for in progress
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: allMealsEaten
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFFF9800),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: allMealsEaten
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 20)
                            : Text(
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Day ${dayIndex + 1}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: allMealsEaten
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFFF9800),
                          ),
                        ),
                        if (allMealsEaten)
                          const Text(
                            'Completed',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),
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
            // Check if meal is logged from mealLogsProvider
            Expanded(
              child: Consumer(
                builder: (context, ref, _) {
                  final mealLogs = ref.watch(mealLogsProvider);
                  final planState = ref.watch(mealPlanNotifierProvider);
                  final mealDate = _resolveMealDateForItem(
                    item,
                    baseDate: planState.result?.mealPlan.date,
                  );

                  // Check if this meal is logged on the correct date
                  final isLogged = mealLogs.any(
                      (log) => _matchesMealLogForMeal(log, item, mealDate));

                  return Row(
                    children: [
                      // Checkbox to mark meal as eaten
                      Checkbox(
                        value: isLogged,
                        onChanged: (value) async {
                          if (value == true) {
                            await _onMealChecked(context, item);
                          } else {
                            _onMealUnchecked(item);
                          }
                        },
                        activeColor: const Color(0xFFFF9800),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      const SizedBox(width: 8),
                      // Meal type badge - consistent width for alignment
                      Container(
                        width: 90,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        decoration: BoxDecoration(
                          color: _getMealTypeColor(item.mealType)
                              .withValues(alpha: isLogged ? 0.08 : 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _getMealTypeColor(item.mealType)
                                .withValues(alpha: isLogged ? 0.15 : 0.3),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _titleCase(item.mealType),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _getMealTypeColor(item.mealType)
                                  .withValues(alpha: isLogged ? 0.5 : 1),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Recipe image - larger
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Opacity(
                          opacity: isLogged ? 0.5 : 1,
                          child: item.recipeImageUrl?.isNotEmpty == true
                              ? Image.network(
                                  item.recipeImageUrl!,
                                  width: 72,
                                  height: 72,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
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
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
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
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: isLogged
                                    ? const Color(0xFF999999)
                                    : const Color(0xFF2D2D2D),
                                decoration: isLogged
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.calories.toStringAsFixed(0)} kcal • ${item.servings.toStringAsFixed(2)} serving${item.servings.toInt() != 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isLogged
                                    ? const Color(0xFFCCCCCC)
                                    : const Color(0xFF666666),
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
                                  color: isLogged
                                      ? const Color(0xFFEEEEEE)
                                      : const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'P: ${item.protein.toStringAsFixed(1)}g | C: ${item.carbohydrates.toStringAsFixed(1)}g | F: ${item.fat.toStringAsFixed(1)}g',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isLogged
                                        ? const Color(0xFFCCCCCC)
                                        : const Color(0xFF666666),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
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
        // View recipe button
        Expanded(
          child: Container(
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFE0B2), width: 1),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: () => _viewRecipeDetails(context, item),
                borderRadius: BorderRadius.circular(8),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.visibility_outlined,
                      size: 18,
                      color: Color(0xFFFF9800),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'View',
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
        const SizedBox(width: 8),
        // Rating button
        Expanded(
          child: Container(
            height: 36,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
        // Replace meal button (disabled if locked)
        if (!item.isLocked) ...[
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFE0B2), width: 1),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () =>
                      _showReplacementDialog(context, mealPlanId, item),
                  borderRadius: BorderRadius.circular(8),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
        ],
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
        String selectedReason = 'dont_like_taste';
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Replace meal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current: ${currentItem.recipeName}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedReason,
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
                        child: Text("Don't like the taste"),
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
                    onChanged: (value) {
                      if (value != null) selectedReason = value;
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    NotificationService.showInfo(
                      context,
                      message: 'Fetching replacement suggestions...',
                    );
                  },
                  child: const Text('Get suggestions'),
                ),
              ],
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

    // Get actual user ID from auth token
    final authToken = ref.read(authTokenProvider);
    final userId = authToken.userId;

    if (userId == null || userId.isEmpty) {
      if (!mounted) return;
      NotificationService.showError(
        context,
        message: 'Error: User authentication required. Please log in again.',
      );
      return;
    }

    const userAge = 30;
    const userGender = "male"; // AI service expects: male, female, or other
    const userHeightCm = 175.0;
    const userWeightKg = 75.0;
    const userGoalWeightKg = 70.0;
    const userHealthGoals =
        "weight_loss"; // AI service expects: weight_loss, muscle_gain, maintenance, etc.
    const userActivityLevel =
        "moderate"; // AI service expects: sedentary, light, moderate, active, very_active
    const dietTypes = <String>[];
    const allergies = <String>[];
    const dislikedIngredients = <String>[];

    // Step 1: Generate preview
    if (!mounted) return;

    try {
      final previewData = await ref
          .read(mealPlanNotifierProvider.notifier)
          .generateMealPlanPreview(
            userId: userId,
            age: userAge,
            gender: userGender,
            heightCm: userHeightCm,
            weightKg: userWeightKg,
            goalWeightKg: userGoalWeightKg,
            healthGoals: userHealthGoals,
            activityLevel: userActivityLevel,
            dietTypes: dietTypes,
            allergies: allergies,
            dislikedIngredients: dislikedIngredients,
            days: days,
          );

      if (!mounted) return;

      if (previewData == null) {
        final state = ref.read(mealPlanNotifierProvider);
        NotificationService.showError(
          context,
          message: 'Error: ${state.error ?? 'Failed to generate preview'}',
        );
        return;
      }

      // Step 2: Show preview screen
      if (!mounted) return;
      final result = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
          builder: (context) => MealPlanPreviewPage(
            previewData: previewData,
            onSaveMealPlan: (modifiedMeals) {
              Navigator.pop(context, modifiedMeals);
            },
          ),
        ),
      );

      if (result == null || !mounted) return;

      // Step 3: Save modified meals
      final savedSuccessfully = await _saveAndShowPreview(
        modifiedMeals: result,
        originalMealPlan:
            previewData['_originalAIMealPlan'] as Map<String, dynamic>,
        mealPlanOptions:
            previewData['_mealPlanOptions'] as Map<String, dynamic>,
        userId: userId,
      );

      if (savedSuccessfully && mounted) {
        NotificationService.showSuccess(
          context,
          message: 'Meal plan saved successfully!',
        );
      }
    } catch (e) {
      if (mounted) {
        NotificationService.showError(context, message: 'Error: $e');
      }
    }
  }

  Future<bool> _saveAndShowPreview({
    required Map<String, dynamic> modifiedMeals,
    required Map<String, dynamic> originalMealPlan,
    required Map<String, dynamic> mealPlanOptions,
    required String userId,
  }) async {
    try {
      await ref.read(mealPlanNotifierProvider.notifier).saveMealPlanFromPreview(
            userId: userId,
            originalAIMealPlan: originalMealPlan,
            mealPlanOptions: mealPlanOptions,
            modifiedMeals: modifiedMeals,
          );

      final state = ref.read(mealPlanNotifierProvider);
      if (state.error != null || state.result == null) {
        return false;
      }

      // Sync meal plan with grocery list
      await _syncMealPlanToGroceryList(state.result!);
      return true;
    } catch (e) {
      if (mounted) {
        NotificationService.showError(context, message: 'Save failed: $e');
      }
      return false;
    }
  }

  /// Syncs the current meal plan to grocery list
  /// Extracts ingredients from all recipes and adds them to grocery list
  Future<void> _syncMealPlanToGroceryList(
    MealPlanGenerationResult mealPlan,
  ) async {
    try {
      if (mealPlan.items.isEmpty) return;

      // Get unique recipe IDs from meal plan
      final recipeIds = mealPlan.items
          .where((item) => item.recipeId != null && item.recipeId!.isNotEmpty)
          .map((item) => item.recipeId!)
          .toSet()
          .toList();

      if (recipeIds.isEmpty) {
        if (mounted) {
          NotificationService.showInfo(
            context,
            message: 'No recipes found in meal plan',
          );
        }
        return;
      }

      // Fetch ingredients for all recipes
      final api = ref.read(recipeIngredientsApiProvider);
      final recipeIngredientsMap = <String, List<dynamic>>{};

      for (final recipeId in recipeIds) {
        try {
          final ingredients = await api.getRecipeIngredients(recipeId);
          recipeIngredientsMap[recipeId] = ingredients;
        } catch (e) {
          debugPrintStack(
            label: '⚠️ Failed to fetch ingredients for recipe $recipeId: $e',
          );
          // Continue with other recipes even if one fails
        }
      }

      // Convert meal plan to grocery items
      final groceryItems =
          MealPlanToGroceryConverter.convertMealPlanToGroceryItems(
        mealPlan,
        recipeIngredientsMap.cast<String, List>(),
      );

      if (groceryItems.isEmpty) {
        if (mounted) {
          NotificationService.showInfo(
            context,
            message: 'No ingredients found to add',
          );
        }
        return;
      }

      // Add items to grocery list
      final groceryNotifier = ref.read(groceryListProvider.notifier);
      await groceryNotifier.addItems(groceryItems);

      if (mounted) {
        NotificationService.showSuccess(
          context,
          message:
              'Grocery list updated with ${groceryItems.length} ingredient(s)',
        );
      }
    } catch (e, st) {
      debugPrintStack(
          label: '❌ Error syncing to grocery list: $e', stackTrace: st);
      if (mounted) {
        NotificationService.showWarning(
          context,
          message: 'Could not update grocery list: $e',
        );
      }
    }
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

    final state = ref.read(mealPlanNotifierProvider);
    if (!mounted) return;

    if (state.error != null) {
      NotificationService.showError(this.context,
          message: 'Error: ${state.error}');
    } else {
      NotificationService.showSuccess(
        this.context,
        message: 'Meal plan optimized successfully!',
      );

      // Sync updated meal plan to grocery list
      if (state.result != null) {
        await _syncMealPlanToGroceryList(state.result!);
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final shouldDelete = await NotificationService.showConfirmation(
      context,
      title: 'Delete meal plans?',
      message:
          'This will remove all meal plans and their meals. This action cannot be undone.',
      confirmText: 'Delete',
      isDangerous: true,
    );

    if (shouldDelete != true) return;

    await ref.read(mealPlanNotifierProvider.notifier).deleteAllMealPlans();
    if (!mounted) return;

    NotificationService.showSuccess(this.context,
        message: 'All meal plans deleted');
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

  /// Navigate to recipe detail page
  void _viewRecipeDetails(BuildContext context, MealPlanItemModel meal) {
    if (meal.recipeId == null || meal.recipeId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe information not available')),
      );
      return;
    }

    // Navigate to recipe details page using GoRouter with the actual recipe ID
    final recipeUrl =
        '/recipe-details/${meal.recipeId}?name=${Uri.encodeComponent(meal.recipeName ?? "Recipe")}&image=${Uri.encodeComponent(meal.recipeImageUrl ?? "")}';

    debugPrint(
        '[_viewRecipeDetails] Navigating to recipe: ${meal.recipeName} (recipeId: ${meal.recipeId})');

    if (context.mounted) {
      context.push(recipeUrl);
    }
  }

  String _titleCase(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }

  String _buildMealPlanTag(String mealPlanItemId) =>
      '[meal_plan_item:$mealPlanItemId]';

  DateTime _resolveMealDateForItem(
    MealPlanItemModel meal, {
    DateTime? baseDate,
  }) {
    final rawBaseDate =
        baseDate ?? ref.read(mealPlanNotifierProvider).result?.mealPlan.date;
    final normalizedBase = rawBaseDate != null
        ? DateTime(rawBaseDate.year, rawBaseDate.month, rawBaseDate.day)
        : DateTime.now();

    final dayDate = normalizedBase.add(Duration(days: meal.dayIndex));

    // Use midday to avoid timezone/date-shift edge cases after serialization.
    return DateTime(dayDate.year, dayDate.month, dayDate.day, 12);
  }

  bool _isSameCalendarDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isDayOneCompletedForToday(MealPlanGenerationResult result) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 12);

    final baseDate = result.mealPlan.date != null
        ? DateTime(
            result.mealPlan.date!.year,
            result.mealPlan.date!.month,
            result.mealPlan.date!.day,
            12,
          )
        : today;

    // Only warn in the scenario user is currently on Day 1 date.
    if (!_isSameCalendarDate(baseDate, today)) {
      return false;
    }

    final dayOneItems =
        result.items.where((item) => item.dayIndex == 0).toList();
    if (dayOneItems.isEmpty) {
      return false;
    }

    final mealLogs = ref.read(mealLogsProvider);

    return dayOneItems.every((item) {
      final dayOneDate = _resolveMealDateForItem(item, baseDate: baseDate);
      return mealLogs
          .any((log) => _matchesMealLogForMeal(log, item, dayOneDate));
    });
  }

  bool _matchesMealLogForMeal(
    MealLog log,
    MealPlanItemModel meal,
    DateTime mealDate,
  ) {
    final mealPlanTag = _buildMealPlanTag(meal.id);
    final sameDate = log.loggedAt.year == mealDate.year &&
        log.loggedAt.month == mealDate.month &&
        log.loggedAt.day == mealDate.day;
    final sameType = log.mealType.toLowerCase() == meal.mealType.toLowerCase();
    final sameName = log.mealName == meal.recipeName;
    final taggedFromMealPlan = log.notes?.contains(mealPlanTag) == true;

    return sameDate && sameType && (taggedFromMealPlan || sameName);
  }

  Future<double?> _showConsumedPortionDialog(
    BuildContext context,
    MealPlanItemModel meal,
  ) async {
    final plannedServings = meal.servings > 0 ? meal.servings.toDouble() : 1.0;
    final controller = TextEditingController(
      text: plannedServings.toStringAsFixed(2),
    );

    return showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('You ate this meal?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Adjust actual serving consumed (default = planned).',
                style: TextStyle(color: Colors.grey[700], fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                'Planned: ${plannedServings.toStringAsFixed(2)} serving${plannedServings == 1 ? '' : 's'}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Actual servings',
                  hintText: 'e.g. 0.6',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final raw = controller.text.trim().replaceAll(',', '.');
                final parsed = double.tryParse(raw);
                if (parsed == null || parsed <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid serving amount > 0'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                Navigator.of(dialogContext).pop(parsed);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  /// Handle meal checked - creates a meal log entry and marks meal as eaten
  Future<void> _onMealChecked(
      BuildContext context, MealPlanItemModel meal) async {
    final state = ref.read(mealPlanNotifierProvider);
    final result = state.result;
    final targetMealDate = _resolveMealDateForItem(
      meal,
      baseDate: result?.mealPlan.date,
    );

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 12);

    if (result != null &&
        _isDayOneCompletedForToday(result) &&
        !_isSameCalendarDate(targetMealDate, today)) {
      NotificationService.showWarning(
        context,
        message:
            'You have completed Day 1 for today. Logging meals from Day ${meal.dayIndex + 1} is blocked to protect your nutrition balance.',
        duration: const Duration(seconds: 4),
      );
      return;
    }

    final consumedServings = await _showConsumedPortionDialog(context, meal);
    if (consumedServings == null) {
      return;
    }
    if (!context.mounted) return;

    // Log meal against its actual meal-plan day.
    final mealDate = _resolveMealDateForItem(meal);
    final plannedServings = meal.servings > 0 ? meal.servings.toDouble() : 1.0;
    final ratio = consumedServings / plannedServings;

    debugPrint('[_onMealChecked] DateTime.now(): ${DateTime.now().toString()}');
    debugPrint(
        '[_onMealChecked] Meal date (year/month/day): ${mealDate.toString()}');
    debugPrint(
        '[_onMealChecked] Meal date ISO8601: ${mealDate.toIso8601String()}');

    // Convert meal type to lowercase for backend compatibility
    final mealTypeInput = meal.mealType.toLowerCase();
    final mealPlanTag = _buildMealPlanTag(meal.id);

    // Create a meal log entry from the meal plan item with STABLE ID
    final mealLog = MealLog(
      id: '${meal.id}_${mealDate.toIso8601String()}',
      mealType: mealTypeInput,
      mealName: meal.recipeName ?? 'Unknown Meal',
      calories: meal.calories * ratio,
      protein: meal.protein * ratio,
      carbs: meal.carbohydrates * ratio,
      fats: meal.fat * ratio,
      quantity: consumedServings,
      unit: 'servings',
      loggedAt: mealDate,
      notes:
          'From meal plan | $mealPlanTag | plannedServings:${plannedServings.toStringAsFixed(2)} | consumedServings:${consumedServings.toStringAsFixed(2)}',
      imageUrl: meal.recipeImageUrl,
    );

    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Saving meal to log...'),
        duration: Duration(seconds: 1),
      ),
    );

    // Add to local state immediately for responsive UI
    ref.read(mealLogsProvider.notifier).addMealLog(mealLog);

    // Update meal plan item state to mark as eaten
    ref
        .read(mealPlanNotifierProvider.notifier)
        .markMealAsEaten(meal.id, DateTime.now());

    // Save to backend asynchronously (fire and forget)
    Future.microtask(() async {
      try {
        final service = ref.read(mealLogServiceProvider);
        final savedMealLog = await service.saveMealLog(mealLog);

        debugPrint(
            '[_onMealChecked] Saved meal - ID: ${savedMealLog.id}, name: ${savedMealLog.mealName}, loggedAt: ${savedMealLog.loggedAt}');

        // Update local state with the real ID from the server
        // First remove the temporary ID version
        debugPrint('[_onMealChecked] Deleting temp ID: ${mealLog.id}');
        ref.read(mealLogsProvider.notifier).deleteMealLog(mealLog.id);

        // Then add the version with the real server ID
        debugPrint('[_onMealChecked] Adding real ID: ${savedMealLog.id}');
        ref.read(mealLogsProvider.notifier).addMealLog(savedMealLog);

        debugPrint(
            '[_onMealChecked] State updated - local mealLogsProvider should now have the saved meal');

        // Set target date and tab for auto-navigation to meal logging
        debugPrint(
            '[_onMealChecked] Setting target date: ${mealDate.toString().split(' ')[0]} and tab index: 1');
        ref.read(targetMealDateProvider.notifier).setTargetDate(mealDate);
        ref
            .read(targetTabIndexProvider.notifier)
            .setTargetTab(1); // Tab 1 = Meal Logging

        // Show success message only if widget still mounted
        if (context.mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${meal.recipeName} logged (${consumedServings.toStringAsFixed(2)} servings)',
              ),
              duration: const Duration(seconds: 2),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  if (!context.mounted) return;

                  // Remove from local state using the real ID
                  ref
                      .read(mealLogsProvider.notifier)
                      .deleteMealLog(savedMealLog.id);

                  // Delete from backend using real ID (fire and forget)
                  ref
                      .read(mealLogServiceProvider)
                      .deleteMealLog(savedMealLog.id)
                      .then((_) {
                    if (context.mounted) {
                      ref
                          .read(mealPlanNotifierProvider.notifier)
                          .markMealAsUneaten(meal.id);
                    }
                  }).catchError((e) {
                    debugPrint('Error deleting from backend: $e');
                  });
                },
              ),
            ),
          );
        }
      } catch (e) {
        // Show error message only if widget still mounted
        if (context.mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving meal: ${e.toString()}'),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.red,
            ),
          );
        }
        debugPrint('Error saving meal log to backend: $e');
      }
    });
  }

  /// Handle meal unchecked - removes meal from meal log
  void _onMealUnchecked(MealPlanItemModel meal) {
    final mealDate = _resolveMealDateForItem(meal);

    // Find the actual meal log by matching its content, not by ID
    final mealLogs = ref.read(mealLogsProvider);
    MealLog? mealLogToDelete;
    try {
      mealLogToDelete = mealLogs.firstWhere(
        (log) => _matchesMealLogForMeal(log, meal, mealDate),
      );
    } catch (e) {
      // Meal log not found in local state
      mealLogToDelete = null;
    }

    // If found, delete it
    if (mealLogToDelete != null) {
      // Capture ID before async closure
      final mealLogId = mealLogToDelete.id;

      // Remove from local state immediately
      ref.read(mealLogsProvider.notifier).deleteMealLog(mealLogId);

      // Mark as uneaten in meal plan state immediately
      ref.read(mealPlanNotifierProvider.notifier).markMealAsUneaten(meal.id);

      // Delete from backend asynchronously (fire and forget)
      Future.microtask(() async {
        try {
          final service = ref.read(mealLogServiceProvider);
          await service.deleteMealLog(mealLogId);
          // Backend deletion complete, local state already updated
        } catch (e) {
          debugPrint('Error deleting meal log from backend: $e');
        }
      });
    }
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

class _DailyMacro {
  final int dayIndex;
  double protein = 0;
  double carbohydrates = 0;
  double fat = 0;

  _DailyMacro({required this.dayIndex});
}
