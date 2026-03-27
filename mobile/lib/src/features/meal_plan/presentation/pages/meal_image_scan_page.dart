import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/meal_image_scan_models.dart';
import '../providers/meal_image_scan_provider.dart';

class MealImageScanPage extends ConsumerWidget {
  const MealImageScanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mealImageScanProvider);
    final notifier = ref.read(mealImageScanProvider.notifier);
    final cameraSupported = notifier.supportsCameraSource;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Scan Meal Image'),
        actions: [
          IconButton(
            onPressed: notifier.clear,
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Take a photo or choose one from gallery. AI will estimate ingredients and nutrition from your local ingredient database.',
                style: TextStyle(fontSize: 14, color: Color(0xFF4E4E4E)),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: state.isLoading || !cameraSupported
                          ? null
                          : () => notifier.pickAndScan(ImageSource.camera),
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: Text(cameraSupported ? 'Camera' : 'Camera N/A'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: state.isLoading
                          ? null
                          : () => notifier.pickAndScan(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Gallery'),
                    ),
                  ),
                ],
              ),
              if (state.imagePath != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFE0B2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.image_outlined,
                          color: Color(0xFFE65100)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          state.imagePath!,
                          style: const TextStyle(fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (state.isLoading) ...[
                const SizedBox(height: 20),
                const LinearProgressIndicator(),
                const SizedBox(height: 10),
                const Text('Analyzing image...'),
              ],
              if (state.error != null) ...[
                const SizedBox(height: 18),
                _ErrorCard(message: state.error!),
              ],
              if (state.result != null) ...[
                const SizedBox(height: 18),
                _ResultCard(result: state.result!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFFB71C1C),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final MealImageScanResult result;

  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.mealName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                  'Confidence: ${(result.confidence * 100).toStringAsFixed(1)}%'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  _MacroChip('Kcal', result.totals.kcal),
                  _MacroChip('Protein', result.totals.protein),
                  _MacroChip('Carbs', result.totals.carbs),
                  _MacroChip('Fats', result.totals.fats),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Detected Ingredients',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        ...result.ingredients.map(_IngredientTile.new),
        const SizedBox(height: 8),
        Text(
          result.note,
          style: const TextStyle(fontSize: 12, color: Color(0xFF6D6D6D)),
        ),
      ],
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final double value;

  const _MacroChip(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label: ${value.toStringAsFixed(2)}'),
      backgroundColor: const Color(0xFFFFF3E0),
      side: const BorderSide(color: Color(0xFFFFCC80)),
    );
  }
}

class _IngredientTile extends StatelessWidget {
  final MealImageScanIngredient ingredient;

  const _IngredientTile(this.ingredient);

  @override
  Widget build(BuildContext context) {
    final isOk = ingredient.status == 'ok';
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOk ? const Color(0xFFB9F6CA) : const Color(0xFFFFCDD2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ingredient.inputName,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                ingredient.status,
                style: TextStyle(
                  fontSize: 12,
                  color:
                      isOk ? const Color(0xFF1B5E20) : const Color(0xFFB71C1C),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Estimated: ${ingredient.estimatedAmount?.toStringAsFixed(2) ?? '-'} ${ingredient.estimatedUnit ?? ''}',
          ),
          Text(
            'Matched: ${ingredient.matchedName ?? '-'}',
          ),
          Text(
            'Converted: ${ingredient.convertedAmount?.toStringAsFixed(2) ?? '-'} ${ingredient.convertedUnit ?? ''}',
          ),
          if (isOk) ...[
            const SizedBox(height: 4),
            Text(
              'Kcal ${ingredient.nutrition.kcal.toStringAsFixed(2)} | P ${ingredient.nutrition.protein.toStringAsFixed(2)} | C ${ingredient.nutrition.carbs.toStringAsFixed(2)} | F ${ingredient.nutrition.fats.toStringAsFixed(2)}',
            ),
          ],
        ],
      ),
    );
  }
}
