// Meal Log Entity
class MealLog {
  final String id;
  final String userId;
  final DateTime dateTime;
  final String mealType; // breakfast, lunch, dinner, snack
  final String? recipeName;
  final String? recipeId;
  final String? customFoodName;
  final int calories;
  final Map<String, double> macros;
  final double servingSize;
  final String? notes;
  final String? imageUrl;

  MealLog({
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
}
