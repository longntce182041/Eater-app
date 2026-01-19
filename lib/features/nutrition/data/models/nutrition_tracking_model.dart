import '../../domain/entities/nutrition_tracking.dart';

class NutritionTrackingModel {
  final String id;
  final String userId;
  final DateTime date;
  final int totalCalories;
  final Map<String, double> totalMacros;
  final Map<String, double> micronutrients;
  final int waterIntake;
  final int calorieGoal;
  final Map<String, double> macroGoals;

  NutritionTrackingModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.totalCalories,
    required this.totalMacros,
    required this.micronutrients,
    required this.waterIntake,
    required this.calorieGoal,
    required this.macroGoals,
  });

  factory NutritionTrackingModel.fromJson(Map<String, dynamic> json) {
    return NutritionTrackingModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      date: DateTime.parse(json['date'] as String),
      totalCalories: json['total_calories'] as int,
      totalMacros: Map<String, double>.from(json['total_macros']),
      micronutrients: Map<String, double>.from(json['micronutrients']),
      waterIntake: json['water_intake'] as int,
      calorieGoal: json['calorie_goal'] as int,
      macroGoals: Map<String, double>.from(json['macro_goals']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String(),
      'total_calories': totalCalories,
      'total_macros': totalMacros,
      'micronutrients': micronutrients,
      'water_intake': waterIntake,
      'calorie_goal': calorieGoal,
      'macro_goals': macroGoals,
    };
  }

  NutritionTracking toEntity() {
    return NutritionTracking(
      id: id,
      userId: userId,
      date: date,
      totalCalories: totalCalories,
      totalMacros: totalMacros,
      micronutrients: micronutrients,
      waterIntake: waterIntake,
      calorieGoal: calorieGoal,
      macroGoals: macroGoals,
    );
  }
}
