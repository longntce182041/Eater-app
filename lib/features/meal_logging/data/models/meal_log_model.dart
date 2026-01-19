import '../../domain/entities/meal_log.dart';

class MealLogModel {
  final String id;
  final String userId;
  final DateTime dateTime;
  final String mealType;
  final String? recipeName;
  final String? recipeId;
  final String? customFoodName;
  final int calories;
  final Map<String, double> macros;
  final double servingSize;
  final String? notes;
  final String? imageUrl;

  MealLogModel({
    required this.id,
    required this.userId,
    required this.dateTime,
    required this.mealType,
    this.recipeName,
    this.recipeId,
    this.customFoodName,
    required this.calories,
    required this.macros,
    required this.servingSize,
    this.notes,
    this.imageUrl,
  });

  factory MealLogModel.fromJson(Map<String, dynamic> json) {
    return MealLogModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      dateTime: DateTime.parse(json['date_time'] as String),
      mealType: json['meal_type'] as String,
      recipeName: json['recipe_name'] as String?,
      recipeId: json['recipe_id'] as String?,
      customFoodName: json['custom_food_name'] as String?,
      calories: json['calories'] as int,
      macros: Map<String, double>.from(json['macros']),
      servingSize: (json['serving_size'] as num).toDouble(),
      notes: json['notes'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date_time': dateTime.toIso8601String(),
      'meal_type': mealType,
      'recipe_name': recipeName,
      'recipe_id': recipeId,
      'custom_food_name': customFoodName,
      'calories': calories,
      'macros': macros,
      'serving_size': servingSize,
      'notes': notes,
      'image_url': imageUrl,
    };
  }

  MealLog toEntity() {
    return MealLog(
      id: id,
      userId: userId,
      dateTime: dateTime,
      mealType: mealType,
      recipeName: recipeName,
      recipeId: recipeId,
      customFoodName: customFoodName,
      calories: calories,
      macros: macros,
      servingSize: servingSize,
      notes: notes,
      imageUrl: imageUrl,
    );
  }
}
