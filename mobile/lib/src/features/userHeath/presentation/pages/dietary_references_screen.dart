import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../providers/dietary_ref_provider.dart';
import '../../../../core/utils/notification_service.dart';

class DietaryReferencesScreen extends ConsumerWidget {
  const DietaryReferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dietaryRefProvider);
    final dietTypesAsync = ref.watch(dietTypesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dietary Preferences',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose diet type and your preferences',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    // Diet types dropdown
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: dietTypesAsync.when(
                        data: (list) {
                          if (list.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                'No diet types available',
                                style: TextStyle(color: Colors.black54),
                              ),
                            );
                          }

                          // Ensure the current value exists in the items list
                          final currentId = state.data.dietTypeId;
                          final validValue =
                              currentId != null &&
                                  list.any((d) => d.id == currentId)
                              ? currentId
                              : null;

                          // Remove any potential duplicates by ID
                          final uniqueItems = <String, dynamic>{};
                          for (var item in list) {
                            uniqueItems[item.id] = item;
                          }

                          return DropdownButtonFormField<String>(
                            key: ValueKey(validValue ?? 'no-selection'),
                            initialValue: validValue,
                            items: uniqueItems.values
                                .map(
                                  (d) => DropdownMenuItem<String>(
                                    value: d.id,
                                    child: Text(d.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              if (v != null) {
                                ref
                                    .read(dietaryRefProvider.notifier)
                                    .setDietType(v);
                              }
                            },
                            decoration: const InputDecoration(
                              labelText: 'Diet type',
                              labelStyle: TextStyle(color: Color(0xFF000000)),
                              border: InputBorder.none,
                            ),
                          );
                        },
                        loading: () => const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: LinearProgressIndicator(),
                        ),
                        error: (e, _) => Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text('Failed to load diet types: $e'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Activity level chips
                    _ChipSelector(
                      label: 'Activity level',
                      values: const [
                        'sedentary',
                        'light',
                        'moderate',
                        'active',
                        'very active',
                      ],
                      selected: state.data.activityLevel ?? 'moderate',
                      onSelected: (v) => ref
                          .read(dietaryRefProvider.notifier)
                          .setActivityLevel(v),
                    ),
                    const SizedBox(height: 16),

                    // Cooking skill chips
                    _ChipSelector(
                      label: 'Cooking skill',
                      values: const ['beginner', 'intermediate', 'advanced'],
                      selected: state.data.cookingSkillLevel ?? 'beginner',
                      onSelected: (v) => ref
                          .read(dietaryRefProvider.notifier)
                          .setCookingSkillLevel(v),
                    ),
                    const SizedBox(height: 16),

                    // Available cooking time
                    _NumberField(
                      label: 'Available cooking time (min)',
                      value: (state.data.availableCookingTime ?? 30).toString(),
                      onChanged: (v) => ref
                          .read(dietaryRefProvider.notifier)
                          .setAvailableCookingTime(int.tryParse(v) ?? 30),
                    ),
                    const SizedBox(height: 16),

                    // Daily calorie target
                    _NumberField(
                      label: 'Daily calorie target (kcal)',
                      value: (state.data.dailyCalorieTarget ?? 2000).toString(),
                      onChanged: (v) => ref
                          .read(dietaryRefProvider.notifier)
                          .setDailyCalorieTarget(int.tryParse(v) ?? 2000),
                    ),
                    const SizedBox(height: 16),

                    // Allergies
                    _TextAreaField(
                      label: 'Allergies (comma or new line separated)',
                      value: state.data.allergies.join(', '),
                      onChanged: (v) {
                        final list = v
                            .split(RegExp('[,\n]'))
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList();
                        ref
                            .read(dietaryRefProvider.notifier)
                            .setAllergies(list);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Dislikes
                    _TextAreaField(
                      label:
                          'Dislike ingredients (comma or new line separated)',
                      value: state.data.dislikesIngredients.join(', '),
                      onChanged: (v) {
                        final list = v
                            .split(RegExp('[,\n]'))
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList();
                        ref
                            .read(dietaryRefProvider.notifier)
                            .setDislikesIngredients(list);
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isLoading
                      ? null
                      : () async {
                          final ok = await ref
                              .read(dietaryRefProvider.notifier)
                              .submitDietaryReferences();
                          if (!context.mounted) return;
                          if (ok) {
                            NotificationService.showSuccess(
                              context,
                              message: 'Dietary preferences saved',
                            );
                            context.go('/home');
                          } else {
                            NotificationService.showError(
                              context,
                              message: 'Failed to save preferences',
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: state.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipSelector extends StatelessWidget {
  final String label;
  final List<String> values;
  final String selected;
  final ValueChanged<String> onSelected;
  const _ChipSelector({
    required this.label,
    required this.values,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D2D2D),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: values
              .map(
                (v) => ChoiceChip(
                  label: Text(v),
                  selected: selected == v,
                  onSelected: (_) => onSelected(v),
                  selectedColor: const Color(0xFFFFE0B2),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _NumberField extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  const _NumberField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(color: Color(0xFF000000)),
        decoration: InputDecoration(labelText: label, border: InputBorder.none),
        controller: TextEditingController(text: value),
        onChanged: onChanged,
      ),
    );
  }
}

class _TextAreaField extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  const _TextAreaField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        maxLines: 4,
        style: const TextStyle(color: Color(0xFF000000)),
        decoration: InputDecoration(labelText: label, border: InputBorder.none),
        controller: TextEditingController(text: value),
        onChanged: onChanged,
      ),
    );
  }
}
