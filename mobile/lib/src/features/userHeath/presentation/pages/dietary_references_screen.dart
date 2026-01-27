import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/providers/dio_provider.dart';
import 'package:dio/dio.dart';

class DietTypeModel {
  final String id;
  final String name;
  final String description;

  DietTypeModel({
    required this.id,
    required this.name,
    required this.description,
  });

  factory DietTypeModel.fromJson(Map<String, dynamic> json) => DietTypeModel(
    id: (json['Diet_TypeId']?.toString() ?? json['_id']?.toString() ?? ''),
    name: json['name']?.toString() ?? '',
    description: json['description']?.toString() ?? '',
  );
}

final dietTypesProvider = FutureProvider<List<DietTypeModel>>((ref) async {
  final dio = ref.watch(dioProvider);
  final res = await dio.get('/api/health/diet-types');
  final List list = res.data is List ? res.data : (res.data['data'] ?? []);
  return list
      .map((e) => DietTypeModel.fromJson(Map<String, dynamic>.from(e)))
      .toList();
});

class DietaryRefState {
  final String? dietTypeId;
  final String activityLevel;
  final String cookingSkillLevel;
  final int availableCookingTime;
  final int dailyCalorieTarget;
  final String allergiesText;
  final String dislikesText;
  final bool isSubmitting;

  DietaryRefState({
    this.dietTypeId,
    this.activityLevel = 'moderate',
    this.cookingSkillLevel = 'beginner',
    this.availableCookingTime = 30,
    this.dailyCalorieTarget = 2000,
    this.allergiesText = '',
    this.dislikesText = '',
    this.isSubmitting = false,
  });

  DietaryRefState copyWith({
    String? dietTypeId,
    String? activityLevel,
    String? cookingSkillLevel,
    int? availableCookingTime,
    int? dailyCalorieTarget,
    String? allergiesText,
    String? dislikesText,
    bool? isSubmitting,
  }) => DietaryRefState(
    dietTypeId: dietTypeId ?? this.dietTypeId,
    activityLevel: activityLevel ?? this.activityLevel,
    cookingSkillLevel: cookingSkillLevel ?? this.cookingSkillLevel,
    availableCookingTime: availableCookingTime ?? this.availableCookingTime,
    dailyCalorieTarget: dailyCalorieTarget ?? this.dailyCalorieTarget,
    allergiesText: allergiesText ?? this.allergiesText,
    dislikesText: dislikesText ?? this.dislikesText,
    isSubmitting: isSubmitting ?? this.isSubmitting,
  );
}

class DietaryRefNotifier extends StateNotifier<DietaryRefState> {
  final Dio _dio;
  DietaryRefNotifier(this._dio) : super(DietaryRefState());

  void setDietType(String? id) => state = state.copyWith(dietTypeId: id);
  void setActivityLevel(String v) => state = state.copyWith(activityLevel: v);
  void setSkillLevel(String v) => state = state.copyWith(cookingSkillLevel: v);
  void setCookingTime(int v) => state = state.copyWith(availableCookingTime: v);
  void setCalorie(int v) => state = state.copyWith(dailyCalorieTarget: v);
  void setAllergies(String v) => state = state.copyWith(allergiesText: v);
  void setDislikes(String v) => state = state.copyWith(dislikesText: v);

  List<String> _splitLines(String input) => input
      .split(RegExp('[,\n]'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  Future<bool> submit() async {
    if (state.dietTypeId == null || state.dietTypeId!.isEmpty) {
      return false;
    }
    state = state.copyWith(isSubmitting: true);
    try {
      final payload = {
        'diet_typeId': state.dietTypeId,
        'allergies': _splitLines(state.allergiesText),
        'dislikesIngredients': _splitLines(state.dislikesText),
        'activityLevel': state.activityLevel,
        'cookingSkillLevel': state.cookingSkillLevel,
        'available_cooking_time': state.availableCookingTime,
        'daily_calorie_target': state.dailyCalorieTarget,
      };
      final res = await _dio.post(
        '/api/health/dietary-references',
        data: payload,
      );
      debugPrint('Dietary refs saved: ${res.data}');
      state = state.copyWith(isSubmitting: false);
      return true;
    } on DioException catch (e) {
      debugPrint('Error: ${e.message}');
      debugPrint('Response: ${e.response?.data}');
      state = state.copyWith(isSubmitting: false);
      return false;
    } catch (e) {
      debugPrint('Unexpected: $e');
      state = state.copyWith(isSubmitting: false);
      return false;
    }
  }
}

final dietaryRefProvider =
    StateNotifierProvider<DietaryRefNotifier, DietaryRefState>((ref) {
      final dio = ref.watch(dioProvider);
      return DietaryRefNotifier(dio);
    });

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
                            color: Colors.black.withOpacity(0.05),
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
                        data: (list) => DropdownButtonFormField<String>(
                          value: state.dietTypeId,
                          items: list
                              .map(
                                (d) => DropdownMenuItem(
                                  value: d.id,
                                  child: Text(d.name),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => ref
                              .read(dietaryRefProvider.notifier)
                              .setDietType(v),
                          decoration: const InputDecoration(
                            labelText: 'Diet type',
                            border: InputBorder.none,
                          ),
                        ),
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
                      selected: state.activityLevel,
                      onSelected: (v) => ref
                          .read(dietaryRefProvider.notifier)
                          .setActivityLevel(v),
                    ),
                    const SizedBox(height: 16),

                    // Cooking skill chips
                    _ChipSelector(
                      label: 'Cooking skill',
                      values: const ['beginner', 'intermediate', 'advanced'],
                      selected: state.cookingSkillLevel,
                      onSelected: (v) => ref
                          .read(dietaryRefProvider.notifier)
                          .setSkillLevel(v),
                    ),
                    const SizedBox(height: 16),

                    // Available cooking time
                    _NumberField(
                      label: 'Available cooking time (min)',
                      value: state.availableCookingTime.toString(),
                      onChanged: (v) => ref
                          .read(dietaryRefProvider.notifier)
                          .setCookingTime(int.tryParse(v) ?? 30),
                    ),
                    const SizedBox(height: 16),

                    // Daily calorie target
                    _NumberField(
                      label: 'Daily calorie target (kcal)',
                      value: state.dailyCalorieTarget.toString(),
                      onChanged: (v) => ref
                          .read(dietaryRefProvider.notifier)
                          .setCalorie(int.tryParse(v) ?? 2000),
                    ),
                    const SizedBox(height: 16),

                    // Allergies
                    _TextAreaField(
                      label: 'Allergies (comma or new line separated)',
                      value: state.allergiesText,
                      onChanged: (v) =>
                          ref.read(dietaryRefProvider.notifier).setAllergies(v),
                    ),
                    const SizedBox(height: 16),

                    // Dislikes
                    _TextAreaField(
                      label:
                          'Dislike ingredients (comma or new line separated)',
                      value: state.dislikesText,
                      onChanged: (v) =>
                          ref.read(dietaryRefProvider.notifier).setDislikes(v),
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
                  onPressed: state.isSubmitting
                      ? null
                      : () async {
                          final ok = await ref
                              .read(dietaryRefProvider.notifier)
                              .submit();
                          if (!context.mounted) return;
                          if (ok) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Dietary preferences saved'),
                              ),
                            );
                            context.go('/home');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to save preferences'),
                              ),
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
                  child: state.isSubmitting
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        maxLines: 4,
        decoration: InputDecoration(labelText: label, border: InputBorder.none),
        controller: TextEditingController(text: value),
        onChanged: onChanged,
      ),
    );
  }
}
