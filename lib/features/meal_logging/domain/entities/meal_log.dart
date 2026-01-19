import 'package:equatable/equatable.dart';

/// Meal log entity for tracking consumed meals.
class MealLog extends Equatable {
  final String id;
  final String userId;
  final DateTime loggedAt;
  final String mealType; // breakfast, lunch, dinner, snack
  final String? recipeId;
  final String? mealPlanMealId;
  final String name;
  final String? imageUrl;
  final int servings;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final String? notes;
  final DateTime? createdAt;

  const MealLog({
    required this.id,
    required this.userId,
    required this.loggedAt,
    required this.mealType,
    this.recipeId,
    this.mealPlanMealId,
    required this.name,
    this.imageUrl,
    this.servings = 1,
    this.calories = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    this.notes,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        loggedAt,
        mealType,
        recipeId,
        mealPlanMealId,
        name,
        imageUrl,
        servings,
        calories,
        protein,
        carbs,
        fat,
        notes,
        createdAt,
      ];
}
