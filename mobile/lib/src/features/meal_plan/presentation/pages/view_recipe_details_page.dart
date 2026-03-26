import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/view_recipe_detail_provider.dart';
import '../widgets/unit_converter_widget.dart';
import '../widgets/micronutrient_unit_converter_widget.dart';

class ViewRecipeDetailsPage extends ConsumerWidget {
  final String recipeId;
  final String? recipeName;
  final String? recipeImageUrl;

  const ViewRecipeDetailsPage({
    super.key,
    required this.recipeId,
    this.recipeName,
    this.recipeImageUrl,
  });

  static const _bgColor = Color(0xFFF5F1E8);
  static const _primary = Color(0xFFFF9800);
  static const _textPrimary = Color.fromARGB(255, 236, 163, 163);
  static const _textSecondary = Color(0xFF666666);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipeDetail = ref.watch(viewRecipeDetailProvider(recipeId));

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          recipeName ?? 'Recipe details',
          style: const TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: _textPrimary),
      ),
      body: recipeDetail.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: _primary),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Error loading recipe',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: _textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
        data: (recipe) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _contentWrap(child: _buildHero(context, recipe)),
            ),
            SliverToBoxAdapter(
              child: _contentWrap(child: _buildNutritionCard(context, recipe)),
            ),
            SliverToBoxAdapter(
              child: _contentWrap(
                  child: _buildIngredientsSection(context, recipe)),
            ),
            SliverToBoxAdapter(
              child: _contentWrap(
                child: _buildMicronutrientsSection(context, recipe),
              ),
            ),
            SliverToBoxAdapter(
              child: _contentWrap(child: _buildStepsSection(context, recipe)),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _contentWrap({required Widget child}) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: child,
      ),
    );
  }

  Widget _buildHero(BuildContext context, Map<String, dynamic> recipe) {
    final name = (recipe['name'] ?? recipeName ?? 'Recipe').toString();
    final description = (recipe['description'] ?? '').toString();
    final cookTime = _toDisplayString(
      recipe['cookingTimeMinutes'] ?? recipe['cookingTime'],
      fallback: '--',
    );
    final servings = _toDisplayString(
      recipe['servings'] ?? recipe['baseServings'],
      fallback: '--',
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: [
          Container(
            height: 230,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey[200],
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (recipeImageUrl != null && recipeImageUrl!.isNotEmpty)
                    Image.network(
                      recipeImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 52,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  else
                    Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.restaurant,
                        size: 64,
                        color: Colors.grey,
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.05),
                          Colors.black.withValues(alpha: 0.5),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetaPill(
                  icon: Icons.schedule,
                  value: '$cookTime min',
                  label: 'Cook time',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetaPill(
                  icon: Icons.people_alt_outlined,
                  value: servings,
                  label: 'Servings',
                ),
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                description,
                style: const TextStyle(
                  color: _textSecondary,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetaPill({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: _primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: _textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard(
      BuildContext context, Map<String, dynamic> recipe) {
    final nutrition = recipe['nutrition'] as Map<String, dynamic>? ?? {};

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: _buildSectionCard(
        title: 'Nutrition Information',
        icon: Icons.pie_chart_outline,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 340;
            final crossAxisCount = isNarrow ? 2 : 4;

            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: isNarrow ? 2.2 : 1.65,
              children: [
                _buildNutrientItem(
                  'Calories',
                  _toDisplayString(nutrition['calories']),
                  'kcal',
                ),
                _buildNutrientItem(
                  'Protein',
                  _toDisplayString(nutrition['protein'], decimals: 1),
                  'g',
                ),
                _buildNutrientItem(
                  'Carbs',
                  _toDisplayString(nutrition['carbohydrates'], decimals: 1),
                  'g',
                ),
                _buildNutrientItem(
                  'Fat',
                  _toDisplayString(
                    nutrition['fat'] ?? nutrition['fats'],
                    decimals: 1,
                  ),
                  'g',
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNutrientItem(String label, String value, String unit) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _primary,
          ),
        ),
        Text(
          unit,
          style: const TextStyle(fontSize: 10, color: _textSecondary),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildIngredientsSection(
      BuildContext context, Map<String, dynamic> recipe) {
    final ingredients = (recipe['ingredients'] as List<dynamic>?) ?? [];

    if (ingredients.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: _buildSectionCard(
        title: 'Ingredients',
        icon: Icons.shopping_basket_outlined,
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: ingredients.length,
          separatorBuilder: (_, __) => const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          itemBuilder: (context, index) {
            final ing = ingredients[index] as Map<String, dynamic>? ?? {};
            final ingredientData =
                ing['ingredientId'] as Map<String, dynamic>? ?? {};
            final quantity = _toDisplayString(
              ing['base_quantity'] ?? ing['baseQuantity'] ?? ing['quantity'],
              fallback: '0',
            );
            final unit = (ing['unit'] ?? 'g').toString();
            final name = (ingredientData['name'] ?? 'Ingredient').toString();
            final micronutrients =
                (ing['micronutrients'] as List<dynamic>?) ?? [];

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: _bgColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: _textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '$quantity $unit',
                              style: const TextStyle(
                                color: _textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Convert quantity',
                        icon: const Icon(
                          Icons.straighten,
                          size: 20,
                          color: _primary,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => UnitConverterWidget(
                              ingredientName: name,
                              baseQuantity: _toDouble(
                                ing['base_quantity'] ??
                                    ing['baseQuantity'] ??
                                    ing['quantity'],
                              ),
                              baseUnit: unit,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  if (micronutrients.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.science_outlined,
                            size: 16, color: _textSecondary),
                        const SizedBox(width: 6),
                        const Text(
                          'Micronutrients',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _textSecondary,
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => MicronutrientUnitConverterWidget(
                                ingredientName: name,
                                micronutrients:
                                    micronutrients.cast<Map<String, dynamic>>(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.scale, size: 16),
                          label: const Text('Convert'),
                          style: TextButton.styleFrom(
                            foregroundColor: _primary,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: micronutrients.map((item) {
                        final micro = item as Map<String, dynamic>? ?? {};
                        final nutrientData =
                            micro['micronutrientId'] as Map<String, dynamic>? ??
                                {};
                        final nutrientName =
                            (nutrientData['name'] ?? 'Nutrient').toString();
                        final amount = _toDisplayString(
                          micro['amount'],
                          fallback: '0',
                          decimals: 2,
                        );
                        final microUnit =
                            (nutrientData['unit'] ?? micro['unit'] ?? 'mg')
                                .toString();

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: _primary.withValues(alpha: 0.2)),
                          ),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: _textPrimary,
                                fontSize: 11,
                              ),
                              children: [
                                TextSpan(
                                  text: '$nutrientName: ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(
                                  text: '$amount $microUnit',
                                  style: const TextStyle(
                                    color: _primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMicronutrientsSection(
    BuildContext context,
    Map<String, dynamic> recipe,
  ) {
    final micronutrients = (recipe['micronutrients'] as List<dynamic>?) ?? [];

    if (micronutrients.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: _buildSectionCard(
        title: 'Micronutrients',
        icon: Icons.biotech_outlined,
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.6,
          ),
          itemCount: micronutrients.length,
          itemBuilder: (context, index) {
            final micro = micronutrients[index] as Map<String, dynamic>? ?? {};
            final nutrientData =
                micro['micronutrientId'] as Map<String, dynamic>? ?? {};
            final name = (nutrientData['name'] ?? 'Nutrient').toString();
            final amount =
                _toDisplayString(micro['amount'], fallback: '0', decimals: 2);
            final unit =
                (nutrientData['unit'] ?? micro['unit'] ?? 'mg').toString();

            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: _textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$amount $unit',
                    style: const TextStyle(
                      color: _primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStepsSection(BuildContext context, Map<String, dynamic> recipe) {
    final steps = (recipe['steps'] as List<dynamic>?) ?? [];

    if (steps.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: _buildSectionCard(
        title: 'Cooking Steps',
        icon: Icons.list_alt_outlined,
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: steps.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final step = steps[index] as Map<String, dynamic>? ?? {};
            final stepNum =
                (step['stepNumber'] ?? step['step'] ?? index + 1).toString();
            final instruction = (step['instruction'] ?? '').toString();

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: _primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        stepNum,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      instruction,
                      style: const TextStyle(
                        color: _textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Widget child,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _primary, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  static String _toDisplayString(
    dynamic value, {
    String fallback = '0',
    int decimals = 0,
  }) {
    if (value == null) return fallback;
    if (value is num) return value.toStringAsFixed(decimals);
    final parsed = double.tryParse(value.toString());
    if (parsed == null) return value.toString();
    return parsed.toStringAsFixed(decimals);
  }
}
