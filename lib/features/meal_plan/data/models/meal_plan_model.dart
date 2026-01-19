import '../../domain/entities/meal_plan.dart';

class MealPlanModel {
  final String id;
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final String planType;
  final List<DailyMealModel> meals;
  final Map<String, dynamic> nutritionSummary;

  MealPlanModel({
    required this.id,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.planType,
    required this.meals,
    required this.nutritionSummary,
  });

  factory MealPlanModel.fromJson(Map<String, dynamic> json) {
    return MealPlanModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      planType: json['plan_type'] as String,
      meals: (json['meals'] as List).map((e) => DailyMealModel.fromJson(e)).toList(),
      nutritionSummary: json['nutrition_summary'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'plan_type': planType,
      'meals': meals.map((e) => e.toJson()).toList(),
      'nutrition_summary': nutritionSummary,
    };
  }

  MealPlan toEntity() {
    return MealPlan(
      id: id,
      userId: userId,
      startDate: startDate,
      endDate: endDate,
      planType: planType,
      meals: meals.map((e) => e.toEntity()).toList(),
      nutritionSummary: nutritionSummary,
    );
  }
}

class DailyMealModel {
  final String id;
  final DateTime date;
  final String mealType;
  final String recipeName;
  final String recipeId;
  final int calories;
  final Map<String, double> macros;

  DailyMealModel({
    required this.id,
    required this.date,
    required this.mealType,
    required this.recipeName,
    required this.recipeId,
    required this.calories,
    required this.macros,
  });

  factory DailyMealModel.fromJson(Map<String, dynamic> json) {
    return DailyMealModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      mealType: json['meal_type'] as String,
      recipeName: json['recipe_name'] as String,
      recipeId: json['recipe_id'] as String,
      calories: json['calories'] as int,
      macros: Map<String, double>.from(json['macros']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'meal_type': mealType,
      'recipe_name': recipeName,
      'recipe_id': recipeId,
      'calories': calories,
      'macros': macros,
    };
  }

  DailyMeal toEntity() {
    return DailyMeal(
      id: id,
      date: date,
      mealType: mealType,
      recipeName: recipeName,
      recipeId: recipeId,
      calories: calories,
      macros: macros,
    );
  }
}
