import '../../domain/entities/meal.dart';

/// Data model for Meal.
class MealModel extends Meal {
  const MealModel({
    required super.id,
    required super.mealPlanId,
    required super.mealType,
    super.recipeId,
    required super.name,
    super.description,
    super.imageUrl,
    super.calories = 0,
    super.protein = 0,
    super.carbs = 0,
    super.fat = 0,
    super.servingSize,
    super.servingUnit,
    required super.scheduledTime,
  });

  /// Creates a MealModel from JSON.
  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      id: json['id'] as String,
      mealPlanId: json['meal_plan_id'] as String,
      mealType: json['meal_type'] as String,
      recipeId: json['recipe_id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      calories: json['calories'] as int? ?? 0,
      protein: json['protein'] as int? ?? 0,
      carbs: json['carbs'] as int? ?? 0,
      fat: json['fat'] as int? ?? 0,
      servingSize: json['serving_size'] as int?,
      servingUnit: json['serving_unit'] as String?,
      scheduledTime: DateTime.parse(json['scheduled_time'] as String),
    );
  }

  /// Converts the model to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meal_plan_id': mealPlanId,
      'meal_type': mealType,
      'recipe_id': recipeId,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'serving_size': servingSize,
      'serving_unit': servingUnit,
      'scheduled_time': scheduledTime.toIso8601String(),
    };
  }
}
