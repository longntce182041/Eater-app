import '../../domain/entities/meal_plan.dart';
import 'meal_model.dart';

/// Data model for MealPlan.
class MealPlanModel extends MealPlan {
  const MealPlanModel({
    required super.id,
    required super.userId,
    required super.date,
    required super.planType,
    super.meals = const [],
    super.totalCalories = 0,
    super.totalProtein = 0,
    super.totalCarbs = 0,
    super.totalFat = 0,
    super.isAiGenerated = false,
    super.createdAt,
    super.updatedAt,
  });

  /// Creates a MealPlanModel from JSON.
  factory MealPlanModel.fromJson(Map<String, dynamic> json) {
    return MealPlanModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      date: DateTime.parse(json['date'] as String),
      planType: json['plan_type'] as String,
      meals: (json['meals'] as List<dynamic>?)
              ?.map((e) => MealModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      totalCalories: json['total_calories'] as int? ?? 0,
      totalProtein: json['total_protein'] as int? ?? 0,
      totalCarbs: json['total_carbs'] as int? ?? 0,
      totalFat: json['total_fat'] as int? ?? 0,
      isAiGenerated: json['is_ai_generated'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Converts the model to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String(),
      'plan_type': planType,
      'meals': meals.map((m) => (m as MealModel).toJson()).toList(),
      'total_calories': totalCalories,
      'total_protein': totalProtein,
      'total_carbs': totalCarbs,
      'total_fat': totalFat,
      'is_ai_generated': isAiGenerated,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
