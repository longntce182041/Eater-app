import 'package:equatable/equatable.dart';

/// Meal entity representing a single meal in a meal plan.
class Meal extends Equatable {
  final String id;
  final String mealPlanId;
  final String mealType; // breakfast, lunch, dinner, snack
  final String? recipeId;
  final String name;
  final String? description;
  final String? imageUrl;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final int? servingSize;
  final String? servingUnit;
  final DateTime scheduledTime;

  const Meal({
    required this.id,
    required this.mealPlanId,
    required this.mealType,
    this.recipeId,
    required this.name,
    this.description,
    this.imageUrl,
    this.calories = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    this.servingSize,
    this.servingUnit,
    required this.scheduledTime,
  });

  @override
  List<Object?> get props => [
        id,
        mealPlanId,
        mealType,
        recipeId,
        name,
        description,
        imageUrl,
        calories,
        protein,
        carbs,
        fat,
        servingSize,
        servingUnit,
        scheduledTime,
      ];
}
