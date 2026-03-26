import 'package:flutter/material.dart';

/// Horizontal scrolling tab bar for guide categories
class CategoryTabBar extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String> onCategorySelect;

  const CategoryTabBar({
    super.key,
    required this.categories,
    this.selectedCategory,
    required this.onCategorySelect,
  });

  Map<String, IconData> get _categoryIcons {
    return {
      'fasting': Icons.schedule,
      'workouts': Icons.fitness_center,
      'nutrition': Icons.restaurant,
      'meal_prep': Icons.restaurant,
      'emotional_eating': Icons.sentiment_satisfied,
      'hydration': Icons.local_drink,
      'stress_management': Icons.spa,
    };
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'fasting':
        return 'Fasting';
      case 'workouts':
        return 'Workouts';
      case 'nutrition':
        return 'Nutrition';
      case 'meal_prep':
        return 'Meal Prep';
      case 'emotional_eating':
        return 'Emotional Eating';
      case 'hydration':
        return 'Hydration';
      case 'stress_management':
        return 'Stress Mgmt';
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: categories.asMap().entries.map((entry) {
          final category = entry.value;
          final isSelected = selectedCategory == category;
          final icon = _categoryIcons[category] ?? Icons.school;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => onCategorySelect(category),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFF9800) : Colors.white,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFFF9800)
                        : Colors.grey[300]!,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      size: 18,
                      color:
                          isSelected ? Colors.white : const Color(0xFF666666),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getCategoryDisplayName(category),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color:
                            isSelected ? Colors.white : const Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
