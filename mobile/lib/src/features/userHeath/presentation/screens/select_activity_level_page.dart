import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/dietary_ref_provider.dart';

class SelectActivityLevelPage extends ConsumerStatefulWidget {
  const SelectActivityLevelPage({super.key});

  @override
  ConsumerState<SelectActivityLevelPage> createState() =>
      _SelectActivityLevelPageState();
}

class _SelectActivityLevelPageState
    extends ConsumerState<SelectActivityLevelPage> {
  final List<Map<String, String>> _activityLevels = [
    {
      'value': 'sedentary',
      'label': 'Sedentary',
      'description': 'Little or no exercise',
    },
    {
      'value': 'light',
      'label': 'Lightly Active',
      'description': 'Light exercise 1-3 days/week',
    },
    {
      'value': 'moderate',
      'label': 'Moderately Active',
      'description': 'Moderate exercise 3-5 days/week',
    },
    {
      'value': 'active',
      'label': 'Very Active',
      'description': 'Hard exercise 6-7 days/week',
    },
    {
      'value': 'very active',
      'label': 'Extra Active',
      'description': 'Very hard exercise & physical job',
    },
  ];

  String? _selectedLevel;
  String? _validationError;

  bool _validate() {
    if (_selectedLevel == null || _selectedLevel!.isEmpty) {
      setState(() {
        _validationError = 'Please select your activity level';
      });
      return false;
    }
    setState(() {
      _validationError = null;
    });
    return true;
  }

  void _continue() {
    if (_validate()) {
      ref.read(dietaryRefProvider.notifier).setActivityLevel(_selectedLevel!);
      context.push('/select-cooking');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Activity Level',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select your typical activity level',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.builder(
                  itemCount: _activityLevels.length,
                  itemBuilder: (context, index) {
                    final level = _activityLevels[index];
                    final isSelected = _selectedLevel == level['value'];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedLevel = level['value'];
                          _validationError = null;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFFF9800)
                                : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    level['label']!,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    level['description']!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFFFF9800),
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_validationError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _validationError!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
