import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cooking_provider.dart';
import '../../domain/cooking_models.dart';

/// Simple cooking steps display screen
class CookingModeScreen extends ConsumerStatefulWidget {
  final String recipeId;
  final int servings;

  const CookingModeScreen({
    super.key,
    required this.recipeId,
    this.servings = 1,
  });

  @override
  ConsumerState<CookingModeScreen> createState() => _CookingModeScreenState();
}

class _CookingModeScreenState extends ConsumerState<CookingModeScreen> {
  @override
  void initState() {
    super.initState();
    // Start cooking session on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cookingModeProvider.notifier).startCooking(
            recipeId: widget.recipeId,
            servings: widget.servings,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final cookingState = ref.watch(cookingModeProvider);

    // Loading state
    if (cookingState.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Starting Cooking...')),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Error state
    if (cookingState.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(cookingState.error ?? 'Unknown error'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final data = cookingState.data;
    if (data == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cooking')),
        body: const Center(child: Text('No data')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(data.recipe.name),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: data.progressPercentage / 100,
            minHeight: 4,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Step ${data.session.currentStepIndex + 1} of ${data.totalSteps}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('${(data.progressPercentage).toStringAsFixed(0)}% done'),
              ],
            ),
          ),
          // Steps content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCurrentStep(data),
                  const SizedBox(height: 32),
                  _buildIngredientsSection(data),
                  const SizedBox(height: 32),
                  _buildTipsSection(data),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          // Action buttons
          _buildActionButtons(context, data),
        ],
      ),
    );
  }

  Widget _buildCurrentStep(CookingModeData data) {
    final step = data.currentStep;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE0B2), width: 2),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              'Step ${step.stepNumber}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            step.instruction,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          if (step.estimatedTime > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.schedule, size: 16, color: Color(0xFFFF9800)),
                const SizedBox(width: 8),
                Text('~${step.estimatedTime ~/ 60} min'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIngredientsSection(CookingModeData data) {
    final step = data.currentStep;
    if (step.ingredients.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ingredients for this step',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: step.ingredients
                .map(
                  (ingredient) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(Icons.circle, size: 6, color: Colors.grey[400]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${ingredient.displayQuantity()} ${ingredient.name}',
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTipsSection(CookingModeData data) {
    final step = data.currentStep;
    if (step.tips.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFB3D9FF)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb, size: 18, color: Color(0xFF1976D2)),
              const SizedBox(width: 8),
              const Text(
                'Pro Tip',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            step.tips,
            style: const TextStyle(height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, CookingModeData data) {
    final isLastStep = data.session.currentStepIndex == data.totalSteps - 1;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          // Previous button
          if (data.session.currentStepIndex > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Going to previous step...')),
                  );
                },
                child: const Text('Previous'),
              ),
            ),
          if (data.session.currentStepIndex > 0) const SizedBox(width: 12),
          // Next/Finish button
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                if (isLastStep) {
                  // Finish cooking
                  await ref.read(cookingModeProvider.notifier).finishCooking();
                  if (mounted && context.mounted) {
                    Navigator.pop(context);
                  }
                } else {
                  // Next step
                  await ref
                      .read(cookingModeProvider.notifier)
                      .completeStep(
                        stepNumber: data.session.currentStepIndex + 1,
                      );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9800),
              ),
              child: Text(
                isLastStep ? 'Finish' : 'Next Step',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
