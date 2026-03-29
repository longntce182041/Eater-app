import 'package:flutter/material.dart';

/// 🏷️ CATEGORY TAB BAR WIDGET
///
/// Horizontal scrolling tab bar for guide categories
/// Shows all category options and highlights selected one
///
/// Layout:
/// ```
/// ◄ [💤 Fasting] [🏋️ Workouts] [🍖 Nutrition] [📝 Meal Prep] [😢 Emotional...] ►
///     ↑ Selected: Orange    Unselected: White with border
/// ```
///
/// Features:
/// - Horizontal scrolling (for many categories)
/// - Each category has icon + label
/// - Selected: Orange background, white text
/// - Unselected: White background, gray border, gray text
/// - Rounded corners (20px pill shape)
/// - Tappable entire category button
///
/// Props:
/// - categories: List of category identifiers
/// - selectedCategory: Currently selected category
/// - onCategorySelect: Callback when user taps category
///
/// Example Usage:
/// ```dart
/// CategoryTabBar(
///   categories: ["fasting", "nutrition", "workouts"],
///   selectedCategory: "fasting",
///   onCategorySelect: (category) {
///     setState(() => _selectedCategory = category);
///   },
/// )
/// ```
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

  /// 🎨 Icon Mapping
  ///
  /// Maps category identifier to Material Design icon
  /// Used to visually represent each category
  ///
  /// Mapping:
  /// - fasting → schedule (clock icon)
  /// - workouts → fitness_center (dumbbell icon)
  /// - nutrition → restaurant (plate icon)
  /// - meal_prep → restaurant (plate icon)
  /// - emotional_eating → sentiment_satisfied (smiley face)
  /// - hydration → local_drink (glass icon)
  /// - stress_management → spa (leaf icon)
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

  /// 📝 Category Display Name
  ///
  /// Converts category identifier to user-friendly display text
  /// Some names shortened for space (e.g., "Stress Mgmt")
  ///
  /// Mapping:
  /// - "fasting" → "Fasting"
  /// - "workouts" → "Workouts"
  /// - "nutrition" → "Nutrition"
  /// - "meal_prep" → "Meal Prep"
  /// - "emotional_eating" → "Emotional Eating" (longer!)
  /// - "hydration" → "Hydration"
  /// - "stress_management" → "Stress Mgmt" (shortened)
  ///
  /// Used in: Tab button label
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
    /// 📱 Horizontal Scrolling Container
    ///
    /// SingleChildScrollView with horizontal axis
    /// Allows many categories to fit in one row
    /// User can swipe to see more categories
    ///
    /// Padding: 16px horizontal (side margins)
    ///          12px vertical (top/bottom spacing)
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

      /// 📌 Row of Category Buttons
      ///
      /// Maps each category to a tab button
      /// Uses asMap().entries to get index (unused but available)
      child: Row(
        children: categories.asMap().entries.map((entry) {
          final category = entry.value;
          final isSelected = selectedCategory == category;
          final icon = _categoryIcons[category] ?? Icons.school;

          /// 🎯 Single Category Button
          ///
          /// Tappable container with icon + label
          /// Color changes based on selection state
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => onCategorySelect(category),

              /// 🎨 Button Container
              ///
              /// Pill-shaped button (20px border radius)
              /// Selected: Orange background, orange border
              /// Unselected: White background, gray border
              child: Container(
                decoration: BoxDecoration(
                  /// Background color based on selection
                  color: isSelected ? const Color(0xFFFF9800) : Colors.white,

                  /// Border color based on selection
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFFF9800)
                        : Colors.grey[300]!,
                  ),

                  /// Rounded corners (pill shape)
                  borderRadius: BorderRadius.circular(20),
                ),

                /// Padding inside button: 16px left/right, 10px top/bottom
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),

                /// 📝 Button Content: Icon + Label
                ///
                /// Row with icon and category name
                /// Icon size: 18pt
                /// Text size: 13pt, 600 weight
                /// White text if selected, gray if not
                child: Row(
                  children: [
                    /// 🎨 Category Icon
                    ///
                    /// Material Design icon specific to category
                    /// Size: 18pt
                    /// Color: White (selected) or Gray (#666)
                    Icon(
                      icon,
                      size: 18,
                      color:
                          isSelected ? Colors.white : const Color(0xFF666666),
                    ),
                    const SizedBox(width: 8),

                    /// 📌 Category Label
                    ///
                    /// User-friendly category name
                    /// Bold text (600 weight)
                    /// Color: White (selected) or Gray (#666)
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
