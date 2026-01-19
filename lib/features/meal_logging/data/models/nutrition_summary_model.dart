import '../../domain/entities/nutrition_summary.dart';

/// Data model for NutritionSummary.
class NutritionSummaryModel extends NutritionSummary {
  const NutritionSummaryModel({
    required super.date,
    super.totalCalories = 0,
    super.targetCalories = 2000,
    super.totalProtein = 0,
    super.targetProtein = 50,
    super.totalCarbs = 0,
    super.targetCarbs = 250,
    super.totalFat = 0,
    super.targetFat = 65,
    super.mealsLogged = 0,
    super.calorieProgress = 0.0,
    super.proteinProgress = 0.0,
    super.carbsProgress = 0.0,
    super.fatProgress = 0.0,
  });

  /// Creates a NutritionSummaryModel from JSON.
  factory NutritionSummaryModel.fromJson(Map<String, dynamic> json) {
    return NutritionSummaryModel(
      date: DateTime.parse(json['date'] as String),
      totalCalories: json['total_calories'] as int? ?? 0,
      targetCalories: json['target_calories'] as int? ?? 2000,
      totalProtein: json['total_protein'] as int? ?? 0,
      targetProtein: json['target_protein'] as int? ?? 50,
      totalCarbs: json['total_carbs'] as int? ?? 0,
      targetCarbs: json['target_carbs'] as int? ?? 250,
      totalFat: json['total_fat'] as int? ?? 0,
      targetFat: json['target_fat'] as int? ?? 65,
      mealsLogged: json['meals_logged'] as int? ?? 0,
      calorieProgress: (json['calorie_progress'] as num?)?.toDouble() ?? 0.0,
      proteinProgress: (json['protein_progress'] as num?)?.toDouble() ?? 0.0,
      carbsProgress: (json['carbs_progress'] as num?)?.toDouble() ?? 0.0,
      fatProgress: (json['fat_progress'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Converts the model to JSON.
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'total_calories': totalCalories,
      'target_calories': targetCalories,
      'total_protein': totalProtein,
      'target_protein': targetProtein,
      'total_carbs': totalCarbs,
      'target_carbs': targetCarbs,
      'total_fat': totalFat,
      'target_fat': targetFat,
      'meals_logged': mealsLogged,
      'calorie_progress': calorieProgress,
      'protein_progress': proteinProgress,
      'carbs_progress': carbsProgress,
      'fat_progress': fatProgress,
    };
  }
}
