import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/recipe_detail_provider.dart';
import '../widgets/unit_converter_widget.dart';

class ViewRecipeDetailPage extends ConsumerWidget {
  final String recipeId;
  final String recipeName;
  final String? recipeImageUrl;

  const ViewRecipeDetailPage({
    super.key,
    required this.recipeId,
    required this.recipeName,
    this.recipeImageUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipeDetailAsync = ref.watch(recipeDetailProvider(recipeId));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F1E8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          recipeName,
          style: const TextStyle(
            color: Color(0xFF2D2D2D),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: recipeDetailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
            ],
          ),
        ),
        data: (recipe) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recipe Image
              if (recipeImageUrl != null && recipeImageUrl!.isNotEmpty)
                Container(
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    image: DecorationImage(
                      image: NetworkImage(recipeImageUrl!),
                      fit: BoxFit.cover,
                      onError: (_, __) {},
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  height: 250,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 48, color: Colors.grey),
                ),
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recipe Info Header
                    _buildRecipeInfoHeader(context, recipe),
                    const SizedBox(height: 24),

                    // Macronutrients Card
                    if (recipe['nutrition'] != null)
                      _buildNutritionCard(context, recipe['nutrition']),
                    const SizedBox(height: 24),

                    // Ingredients Section
                    if (recipe['ingredients'] != null &&
                        (recipe['ingredients'] as List).isNotEmpty)
                      _buildIngredientsSection(context, recipe),
                    const SizedBox(height: 24),

                    // Micronutrients Section
                    if (recipe['micronutrients'] != null &&
                        (recipe['micronutrients'] as List).isNotEmpty)
                      _buildMicronutrientsSection(context, recipe),
                    const SizedBox(height: 24),

                    // Steps Section
                    if (recipe['steps'] != null &&
                        (recipe['steps'] as List).isNotEmpty)
                      _buildStepsSection(context, recipe),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeInfoHeader(
      BuildContext context, Map<String, dynamic> recipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          recipe['name'] ?? '',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            if (recipe['cookingTime'] != null)
              Expanded(
                child: _buildInfoChip(
                  '⏱ ${recipe['cookingTime']} min',
                  'Cooking Time',
                ),
              ),
            const SizedBox(width: 8),
            if (recipe['baseServings'] != null)
              Expanded(
                child: _buildInfoChip(
                  '🍽 ${recipe['baseServings']}',
                  'Servings',
                ),
              ),
            const SizedBox(width: 8),
            if (recipe['rating'] != null)
              Expanded(
                child: _buildInfoChip(
                  '⭐ ${(recipe['rating'] as num).toStringAsFixed(1)}',
                  'Rating',
                ),
              ),
          ],
        ),
        if (recipe['description'] != null &&
            (recipe['description'] as String).isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(
                recipe['description'],
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildInfoChip(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9800).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFFF9800).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF9800),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard(
      BuildContext context, Map<String, dynamic> nutrition) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nutrition Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildNutrientItem(
                  'Calories',
                  '${(nutrition['calories'] as num?)?.toStringAsFixed(0) ?? 0}',
                  'kcal',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildNutrientItem(
                  'Protein',
                  '${(nutrition['protein'] as num?)?.toStringAsFixed(1) ?? 0}',
                  'g',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildNutrientItem(
                  'Carbs',
                  '${(nutrition['carbohydrates'] as num?)?.toStringAsFixed(1) ?? 0}',
                  'g',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildNutrientItem(
                  'Fat',
                  '${(nutrition['fat'] as num?)?.toStringAsFixed(1) ?? 0}',
                  'g',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientItem(String name, String value, String unit) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF9800),
          ),
        ),
        Text(
          unit,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF2D2D2D),
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientsSection(
      BuildContext context, Map<String, dynamic> recipe) {
    final ingredients = recipe['ingredients'] as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ingredients',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ingredients.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final ingredient = ingredients[index] as Map<String, dynamic>;
              final ingredientData =
                  ingredient['ingredientId'] as Map<String, dynamic>?;
              final name = ingredientData?['name'] ?? 'Unknown';
              final quantity = ingredient['base_quantity'] ?? '0';
              final unit = ingredient['unit'] ?? '';

              return Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name.toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D2D2D),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$quantity $unit',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.scale,
                        color: Color(0xFFFF9800),
                        size: 20,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => UnitConverterWidget(
                            ingredientName: name.toString(),
                            baseQuantity:
                                double.tryParse(quantity.toString()) ?? 0,
                            baseUnit: unit.toString(),
                          ),
                        );
                      },
                      tooltip: 'Convert unit',
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMicronutrientsSection(
      BuildContext context, Map<String, dynamic> recipe) {
    final micronutrients = recipe['micronutrients'] as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Micronutrients',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
              ),
            ],
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            itemCount: micronutrients.length,
            itemBuilder: (context, index) {
              final micronutrient =
                  micronutrients[index] as Map<String, dynamic>;
              final nutriData =
                  micronutrient['micronutrientId'] as Map<String, dynamic>?;
              final name = nutriData?['name'] ?? 'Unknown';
              final amount = micronutrient['amount'] ?? 0;
              final unit = nutriData?['unit'] ?? '';

              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFFF9800).withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$amount $unit',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStepsSection(BuildContext context, Map<String, dynamic> recipe) {
    final steps = recipe['steps'] as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cooking Steps',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: steps.length,
          itemBuilder: (context, index) {
            final step = steps[index] as Map<String, dynamic>;
            final stepNumber = step['stepNumber'] ?? index + 1;
            final instruction = step['instruction'] ?? '';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF9800),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        stepNumber.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      instruction.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2D2D2D),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
