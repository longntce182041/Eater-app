import 'package:equatable/equatable.dart';

import 'meal.dart';

/// Meal plan entity representing a daily or weekly meal plan.
class MealPlan extends Equatable {
  final String id;
  final String userId;
  final DateTime date;
  final String planType; // 'daily' or 'weekly'
  final List<Meal> meals;
  final int totalCalories;
  final int totalProtein;
  final int totalCarbs;
  final int totalFat;
  final bool isAiGenerated;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MealPlan({
    required this.id,
    required this.userId,
    required this.date,
    required this.planType,
    this.meals = const [],
    this.totalCalories = 0,
    this.totalProtein = 0,
    this.totalCarbs = 0,
    this.totalFat = 0,
    this.isAiGenerated = false,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        date,
        planType,
        meals,
        totalCalories,
        totalProtein,
        totalCarbs,
        totalFat,
        isAiGenerated,
        createdAt,
        updatedAt,
      ];
}
