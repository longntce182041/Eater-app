// Dietary Preferences Entity
class DietaryPreferences {
  final String id;
  final String userId;
  final String dietType; // vegan, vegetarian, keto, paleo, etc.
  final List<String> foodAllergies;
  final List<String> foodDislikes;
  final List<String> cuisinePreferences;
  final int calorieTarget;
  final Map<String, double> macroTargets; // protein, carbs, fats

  DietaryPreferences({
    required this.id,
    required this.userId,
    required this.dietType,
    required this.foodAllergies,
    required this.foodDislikes,
    required this.cuisinePreferences,
    required this.calorieTarget,
    required this.macroTargets,
  });
}
