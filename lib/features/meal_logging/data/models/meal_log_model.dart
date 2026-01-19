import '../../domain/entities/meal_log.dart';

/// Data model for MealLog.
class MealLogModel extends MealLog {
  const MealLogModel({
    required super.id,
    required super.userId,
    required super.loggedAt,
    required super.mealType,
    super.recipeId,
    super.mealPlanMealId,
    required super.name,
    super.imageUrl,
    super.servings = 1,
    super.calories = 0,
    super.protein = 0,
    super.carbs = 0,
    super.fat = 0,
    super.notes,
    super.createdAt,
  });

  /// Creates a MealLogModel from JSON.
  factory MealLogModel.fromJson(Map<String, dynamic> json) {
    return MealLogModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      loggedAt: DateTime.parse(json['logged_at'] as String),
      mealType: json['meal_type'] as String,
      recipeId: json['recipe_id'] as String?,
      mealPlanMealId: json['meal_plan_meal_id'] as String?,
      name: json['name'] as String,
      imageUrl: json['image_url'] as String?,
      servings: json['servings'] as int? ?? 1,
      calories: json['calories'] as int? ?? 0,
      protein: json['protein'] as int? ?? 0,
      carbs: json['carbs'] as int? ?? 0,
      fat: json['fat'] as int? ?? 0,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Converts the model to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'logged_at': loggedAt.toIso8601String(),
      'meal_type': mealType,
      'recipe_id': recipeId,
      'meal_plan_meal_id': mealPlanMealId,
      'name': name,
      'image_url': imageUrl,
      'servings': servings,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
