import 'package:equatable/equatable.dart';

/// Nutrition summary entity for daily/weekly tracking.
class NutritionSummary extends Equatable {
  final DateTime date;
  final int totalCalories;
  final int targetCalories;
  final int totalProtein;
  final int targetProtein;
  final int totalCarbs;
  final int targetCarbs;
  final int totalFat;
  final int targetFat;
  final int mealsLogged;
  final double calorieProgress;
  final double proteinProgress;
  final double carbsProgress;
  final double fatProgress;

  const NutritionSummary({
    required this.date,
    this.totalCalories = 0,
    this.targetCalories = 2000,
    this.totalProtein = 0,
    this.targetProtein = 50,
    this.totalCarbs = 0,
    this.targetCarbs = 250,
    this.totalFat = 0,
    this.targetFat = 65,
    this.mealsLogged = 0,
    this.calorieProgress = 0.0,
    this.proteinProgress = 0.0,
    this.carbsProgress = 0.0,
    this.fatProgress = 0.0,
  });

  /// Remaining calories for the day.
  int get remainingCalories => targetCalories - totalCalories;

  /// Whether user is over calorie target.
  bool get isOverCalories => totalCalories > targetCalories;

  @override
  List<Object?> get props => [
        date,
        totalCalories,
        targetCalories,
        totalProtein,
        targetProtein,
        totalCarbs,
        targetCarbs,
        totalFat,
        targetFat,
        mealsLogged,
        calorieProgress,
        proteinProgress,
        carbsProgress,
        fatProgress,
      ];
}
