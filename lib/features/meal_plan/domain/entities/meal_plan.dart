// Meal Plan Entity
class MealPlan {
  final String id;
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final String planType; // daily, weekly
  final List<DailyMeal> meals;
  final Map<String, dynamic> nutritionSummary;

  MealPlan({
    required this.id,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.planType,
    required this.meals,
    required this.nutritionSummary,
  });
}

class DailyMeal {
  final String id;
  final DateTime date;
  final String mealType; // breakfast, lunch, dinner, snack
  final String recipeName;
  final String recipeId;
  final int calories;
  final Map<String, double> macros;

  DailyMeal({
    required this.id,
    required this.date,
    required this.mealType,
    required this.recipeName,
    required this.recipeId,
    required this.calories,
    required this.macros,
  });
}
