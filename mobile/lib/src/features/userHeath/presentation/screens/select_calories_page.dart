import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/dietary_ref_provider.dart';
import '../../../../core/utils/notification_service.dart';

class SelectCaloriesPage extends ConsumerStatefulWidget {
  const SelectCaloriesPage({super.key});

  @override
  ConsumerState<SelectCaloriesPage> createState() => _SelectCaloriesPageState();
}

class _SelectCaloriesPageState extends ConsumerState<SelectCaloriesPage> {
  int? _dailyCalories;
  String? _validationError;

  final TextEditingController _caloriesController = TextEditingController();
  static const int _minCalories = 1200;
  static const int _maxCalories = 4000;
  final List<int> _quickPicks = const [1500, 1800, 2000, 2300, 2600];

  @override
  void initState() {
    super.initState();
    _dailyCalories = 2000;
    _caloriesController.text = '2000';
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    super.dispose();
  }

  bool _validate() {
    if (_dailyCalories == null || _dailyCalories! <= 0) {
      setState(() {
        _validationError = 'Please enter a valid daily calorie target';
      });
      return false;
    }
    if (_dailyCalories! < 1000) {
      setState(() {
        _validationError = 'Calorie target should be at least 1000 calories';
      });
      return false;
    }
    if (_dailyCalories! > 5000) {
      setState(() {
        _validationError = 'Calorie target should not exceed 5000 calories';
      });
      return false;
    }
    setState(() {
      _validationError = null;
    });
    return true;
  }

  Future<void> _submit() async {
    if (_validate()) {
      ref
          .read(dietaryRefProvider.notifier)
          .setDailyCalorieTarget(_dailyCalories!);

      final success = await ref
          .read(dietaryRefProvider.notifier)
          .submitDietaryReferences();

      if (!mounted) return;

      if (success) {
        NotificationService.showSuccess(
          context,
          message: 'Dietary preferences saved successfully!',
        );
        // Navigate to profile summary or home
        context.go('/home');
      } else {
        final error =
            ref.read(dietaryRefProvider).errorMessage ??
            'Failed to save preferences';
        NotificationService.showError(context, message: error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dietaryRefState = ref.watch(dietaryRefProvider);
    final bool isSubmitting = dietaryRefState.isLoading;
    final double sliderValue = (_dailyCalories ?? 2000).toDouble();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _OnboardingProgressBar(),
                  SizedBox(height: 24),
                  Text(
                    'Daily calorie target',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Dial in a target so we can balance meals for your day.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 16),
                  _InfoCard(),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Target calories',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _caloriesController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: '2000',
                                    hintStyle: const TextStyle(
                                      color: Color(0xFF000000),
                                    ),
                                    suffixText: 'kcal',
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF000000),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _dailyCalories = int.tryParse(value);
                                      _validationError = null;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A237E),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.local_fire_department,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Slider(
                            value: sliderValue
                                .clamp(
                                  _minCalories.toDouble(),
                                  _maxCalories.toDouble(),
                                )
                                .toDouble(),
                            min: _minCalories.toDouble(),
                            max: _maxCalories.toDouble(),
                            divisions: (_maxCalories - _minCalories) ~/ 50,
                            activeColor: const Color(0xFF1A237E),
                            inactiveColor: Colors.deepOrange.shade100,
                            label: '${sliderValue.toInt()} kcal',
                            onChanged: (value) {
                              final int rounded = (value / 50).round() * 50;
                              setState(() {
                                _dailyCalories = rounded;
                                _caloriesController.text = rounded.toString();
                                _validationError = null;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _quickPicks.map((calories) {
                              final bool selected = _dailyCalories == calories;
                              return ChoiceChip(
                                label: Text('$calories kcal'),
                                selected: selected,
                                selectedColor: const Color(0xFFFCE8D8),
                                labelStyle: TextStyle(
                                  color: selected
                                      ? Colors.deepOrange
                                      : Colors.black87,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                onSelected: (_) {
                                  setState(() {
                                    _dailyCalories = calories;
                                    _caloriesController.text = calories
                                        .toString();
                                    _validationError = null;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _RecommendationsCard(),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_validationError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _validationError!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: isSubmitting ? null : () => context.pop(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A237E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.grey,
                        elevation: 0,
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Complete setup',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingProgressBar extends StatelessWidget {
  const _OnboardingProgressBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _ProgressSegment(color: Colors.green, isActive: true),
        SizedBox(width: 6),
        _ProgressSegment(color: Colors.yellow, isActive: true),
        SizedBox(width: 6),
        _ProgressSegment(color: Colors.orange, isActive: true),
        SizedBox(width: 6),
        _ProgressSegment(color: Colors.deepOrange, isActive: true),
        SizedBox(width: 6),
        _ProgressSegment(color: Colors.deepOrange, isActive: false),
      ],
    );
  }
}

class _ProgressSegment extends StatelessWidget {
  final Color color;
  final bool isActive;

  const _ProgressSegment({required this.color, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 8,
        decoration: BoxDecoration(
          color: isActive ? color : color.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4C99E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.balance,
              size: 32,
              color: Colors.deepOrange,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'We’ll tailor portions and macro splits to keep your days balanced.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Why?',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Recommended ranges',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.deepOrange,
            ),
          ),
          SizedBox(height: 12),
          _RecommendationRow(label: 'Weight loss', value: '1,200 - 1,800 kcal'),
          _RecommendationRow(label: 'Maintenance', value: '1,800 - 2,400 kcal'),
          _RecommendationRow(label: 'Muscle gain', value: '2,400 - 3,000 kcal'),
          _RecommendationRow(label: 'Athletic', value: '3,000 - 4,000 kcal'),
        ],
      ),
    );
  }
}

class _RecommendationRow extends StatelessWidget {
  final String label;
  final String value;

  const _RecommendationRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
