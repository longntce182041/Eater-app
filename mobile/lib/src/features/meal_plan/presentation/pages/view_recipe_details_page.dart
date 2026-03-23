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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipeDetail = ref.watch(viewRecipeDetailProvider(recipeId));

    return Scaffold(
      appBar: AppBar(
        title: Text(recipeName ?? 'Recipe Details'),
        centerTitle: true,
      ),
      body: recipeDetail.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF9800)),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading recipe'),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
        data: (recipe) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recipe Image
              _buildRecipeImage(),
              
              // Recipe Info Header
              _buildRecipeInfoHeader(context, recipe),
              
              // Nutrition Card
              _buildNutritionCard(context, recipe),
              
              // Ingredients
              _buildIngredientsSection(context, recipe),
              
              // Micronutrients
              _buildMicronutrientsSection(context, recipe),
              
              // Cooking Steps
              _buildStepsSection(context, recipe),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeImage() {
    return Container(
      width: double.infinity,
      height: 250,
      color: Colors.grey[200],
      child: recipeImageUrl != null && recipeImageUrl!.isNotEmpty
          ? Image.network(
              recipeImageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                );
              },
            )
          : const Center(
              child: Icon(Icons.restaurant, size: 64, color: Colors.grey),
            ),
    );
  }

  Widget _buildRecipeInfoHeader(BuildContext context, Map<String, dynamic> recipe) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            recipe['name'] ?? 'Recipe',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip('⏱️ ${recipe['cookingTimeMinutes'] ?? 30} min'),
              const SizedBox(width: 8),
              _buildInfoChip('🍽️ ${recipe['servings'] ?? 1} servings'),
              const SizedBox(width: 8),
              _buildInfoChip('⭐ ${recipe['rating'] ?? 4.5}'),
            ],
          ),
          if (recipe['description'] != null && (recipe['description'] as String).isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              recipe['description'] ?? '',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9800).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFFFF9800),
        ),
      ),
    );
  }

  Widget _buildNutritionCard(BuildContext context, Map<String, dynamic> recipe) {
    final nutrition = recipe['nutrition'] as Map<String, dynamic>? ?? {};

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nutrition Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildNutrientItem(
                  'Calories',
                  nutrition['calories']?.toString() ?? '0',
                  'kcal',
                ),
                _buildNutrientItem(
                  'Protein',
                  nutrition['protein']?.toStringAsFixed(1) ?? '0.0',
                  'g',
                ),
                _buildNutrientItem(
                  'Carbs',
                  nutrition['carbohydrates']?.toStringAsFixed(1) ?? '0.0',
                  'g',
                ),
                _buildNutrientItem(
                  'Fat',
                  nutrition['fats']?.toStringAsFixed(1) ?? '0.0',
                  'g',
                ),
              ],
            ),
          ],
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
            color: Color(0xFFFF9800),
          ),
        ),
        Text(
          unit,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildIngredientsSection(BuildContext context, Map<String, dynamic> recipe) {
    final ingredients = (recipe['ingredients'] as List<dynamic>?) ?? [];

    if (ingredients.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ingredients',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ingredients.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final ing = ingredients[index] as Map<String, dynamic>?;
              final ingredientData = ing?['ingredientId'] as Map<String, dynamic>? ?? {};
              final quantity = ing?['base_quantity']?.toString() ?? '0';
              final unit = ing?['unit']?.toString() ?? 'g';
              final name = ingredientData['name']?.toString() ?? 'Ingredient';
              final micronutrients = (ing?['micronutrients'] as List<dynamic>?) ?? [];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '$quantity $unit',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Unit converter for ingredient quantity
                      IconButton(
                        icon: const Icon(Icons.straighten, size: 20),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => UnitConverterWidget(
                              ingredientName: name,
                              baseQuantity: double.tryParse(quantity) ?? 0,
                              baseUnit: unit,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  
                  // Micronutrients section for this ingredient
                  if (micronutrients.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Micronutrients:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => MicronutrientUnitConverterWidget(
                                ingredientName: name,
                                micronutrients: micronutrients.cast<Map<String, dynamic>>(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.scale, size: 16),
                          label: const Text('Convert Units'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFFF9800),
                          ),
                        ),
                      ],
                    ),
                    // Display micronutrients in grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 2.5,
                      ),
                      itemCount: micronutrients.length,
                      itemBuilder: (context, microIndex) {
                        final micro = micronutrients[microIndex] as Map<String, dynamic>?;
                        final nutrientData = micro?['micronutrientId'] as Map<String, dynamic>? ?? {};
                        final nutrientName = nutrientData['name']?.toString() ?? 'Nutrient';
                        final amount = micro?['amount']?.toString() ?? '0';
                        final microUnit = 'mg';

                        return Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9800).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFFFF9800).withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nutrientName,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$amount $microUnit',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF9800),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMicronutrientsSection(BuildContext context, Map<String, dynamic> recipe) {
    final micronutrients = (recipe['micronutrients'] as List<dynamic>?) ?? [];

    if (micronutrients.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Micronutrients',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
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
              final micro = micronutrients[index] as Map<String, dynamic>?;
              final nutrientData = micro?['micronutrientId'] as Map<String, dynamic>? ?? {};
              final name = nutrientData['name']?.toString() ?? 'Nutrient';
              final amount = micro?['amount']?.toString() ?? '0';
              final unit = micro?['unit']?.toString() ?? 'mg';

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFFF9800).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$amount $unit',
                      style: const TextStyle(
                        color: Color(0xFFFF9800),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStepsSection(BuildContext context, Map<String, dynamic> recipe) {
    final steps = (recipe['steps'] as List<dynamic>?) ?? [];

    if (steps.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cooking Steps',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: steps.length,
            itemBuilder: (context, index) {
              final step = steps[index] as Map<String, dynamic>?;
              final stepNum = (step?['stepNumber'] ?? index + 1).toString();
              final instruction = step?['instruction']?.toString() ?? '';

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9800),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          stepNum,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        instruction,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
