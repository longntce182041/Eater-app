// Nutrition Tracking Entity
class NutritionTracking {
  final String id;
  final String userId;
  final DateTime date;
  final int totalCalories;
  final Map<String, double> totalMacros; // protein, carbs, fats
  final Map<String, double> micronutrients; // vitamins, minerals
  final int waterIntake; // in ml
  final int calorieGoal;
  final Map<String, double> macroGoals;

  NutritionTracking({
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
}
