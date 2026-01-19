import '../../domain/entities/dietary_preferences.dart';

class DietaryPreferencesModel {
  final String id;
  final String userId;
  final String dietType;
  final List<String> foodAllergies;
  final List<String> foodDislikes;
  final List<String> cuisinePreferences;
  final int calorieTarget;
  final Map<String, double> macroTargets;

  DietaryPreferencesModel({
    required this.id,
    required this.userId,
    required this.dietType,
    required this.foodAllergies,
    required this.foodDislikes,
    required this.cuisinePreferences,
    required this.calorieTarget,
    required this.macroTargets,
  });

  factory DietaryPreferencesModel.fromJson(Map<String, dynamic> json) {
    return DietaryPreferencesModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      dietType: json['diet_type'] as String,
      foodAllergies: (json['food_allergies'] as List).cast<String>(),
      foodDislikes: (json['food_dislikes'] as List).cast<String>(),
      cuisinePreferences: (json['cuisine_preferences'] as List).cast<String>(),
      calorieTarget: json['calorie_target'] as int,
      macroTargets: Map<String, double>.from(json['macro_targets']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'diet_type': dietType,
      'food_allergies': foodAllergies,
      'food_dislikes': foodDislikes,
      'cuisine_preferences': cuisinePreferences,
      'calorie_target': calorieTarget,
      'macro_targets': macroTargets,
    };
  }

  DietaryPreferences toEntity() {
    return DietaryPreferences(
      id: id,
      userId: userId,
      dietType: dietType,
      foodAllergies: foodAllergies,
      foodDislikes: foodDislikes,
      cuisinePreferences: cuisinePreferences,
      calorieTarget: calorieTarget,
      macroTargets: macroTargets,
    );
  }
}
