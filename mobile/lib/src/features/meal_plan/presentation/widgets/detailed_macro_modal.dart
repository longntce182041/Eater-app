import 'package:flutter/material.dart';

class DailyMicronutrient {
  final String name;
  final String unit;
  final double amount;

  const DailyMicronutrient({
    required this.name,
    required this.unit,
    required this.amount,
  });

  DailyMicronutrient copyWith({
    String? name,
    String? unit,
    double? amount,
  }) {
    return DailyMicronutrient(
      name: name ?? this.name,
      unit: unit ?? this.unit,
      amount: amount ?? this.amount,
    );
  }
}

/// Data class to hold daily macro totals
class DailyMacro {
  final int dayIndex;
  double protein;
  double carbohydrates;
  double fat;
  final List<DailyMicronutrient>? micronutrients;

  List<DailyMicronutrient> get safeMicronutrients => micronutrients ?? const [];

  DailyMacro({
    required this.dayIndex,
    this.protein = 0,
    this.carbohydrates = 0,
    this.fat = 0,
    this.micronutrients = const [],
  });
}

class DetailedMacroBottomSheet extends StatefulWidget {
  final List<DailyMacro> dailyMacros;
  final int initialDay;

  const DetailedMacroBottomSheet({
    super.key,
    required this.dailyMacros,
    this.initialDay = 0,
  });

  @override
  State<DetailedMacroBottomSheet> createState() =>
      _DetailedMacroBottomSheetState();
}

class _DetailedMacroBottomSheetState extends State<DetailedMacroBottomSheet> {
  late int selectedDayIndex;

  @override
  void initState() {
    super.initState();
    if (widget.dailyMacros.isEmpty) {
      selectedDayIndex = 0;
      return;
    }

    selectedDayIndex =
        widget.initialDay.clamp(0, widget.dailyMacros.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dailyMacros.isEmpty) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('No macro data available'),
          ),
        ),
      );
    }

    final currentDay = widget.dailyMacros[selectedDayIndex];
    final hasMultipleDays = widget.dailyMacros.length > 1;

    return SafeArea(
      bottom: true,
      child: Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.0),
        child: Container(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Macro breakdown',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Day ${currentDay.dayIndex + 1} of ${widget.dailyMacros.length}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 0, thickness: 1),

              // Day selector (if multiple days)
              if (hasMultipleDays) ...[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select day',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 44,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.dailyMacros.length,
                          itemBuilder: (context, index) {
                            final isSelected = index == selectedDayIndex;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() => selectedDayIndex = index);
                                },
                                child: Container(
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFFF9800)
                                        : const Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFFFF9800)
                                          : const Color(0xFFE0E0E0),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFF666666),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 0, thickness: 1),
              ],

              // Macro breakdown with percentages
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Macronutrients',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMacroItem(
                      label: 'Protein',
                      value: currentDay.protein,
                      targetValue: 60.0,
                      color: const Color(0xFF42A5F5),
                      abbreviation: 'P',
                    ),
                    const SizedBox(height: 10),
                    _buildMacroItem(
                      label: 'Carbohydrates',
                      value: currentDay.carbohydrates,
                      targetValue: 200.0,
                      color: const Color(0xFFFFC107),
                      abbreviation: 'C',
                    ),
                    const SizedBox(height: 10),
                    _buildMacroItem(
                      label: 'Fat',
                      value: currentDay.fat,
                      targetValue: 50.0,
                      color: const Color(0xFFFF7043),
                      abbreviation: 'F',
                    ),
                  ],
                ),
              ),

              const Divider(height: 0, thickness: 1),

              // Micronutrients (if available)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nutritional summary',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildNutrientStat(
                      label: 'Total calories',
                      value:
                          '${(currentDay.protein * 4 + currentDay.carbohydrates * 4 + currentDay.fat * 9).toStringAsFixed(0)} kcal',
                    ),
                    const SizedBox(height: 8),
                    _buildNutrientStat(
                      label: 'Total weight',
                      value:
                          '${(currentDay.protein + currentDay.carbohydrates + currentDay.fat).toStringAsFixed(0)} g',
                    ),
                    if (currentDay.safeMicronutrients.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Total micronutrients',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...currentDay.safeMicronutrients.map(
                        (micro) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: _buildNutrientStat(
                            label: micro.name,
                            value:
                                '${micro.amount.toStringAsFixed(2)} ${micro.unit}',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroItem({
    required String label,
    required double value,
    required double targetValue,
    required Color color,
    required String abbreviation,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  abbreviation,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  Text(
                    '${value.toStringAsFixed(1)}g',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildNutrientStat({
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF666666),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D2D2D),
          ),
        ),
      ],
    );
  }
}
