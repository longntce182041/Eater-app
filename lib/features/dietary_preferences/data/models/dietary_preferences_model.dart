import '../../domain/entities/dietary_preferences.dart';

/// Data model for DietaryPreferences.
class DietaryPreferencesModel extends DietaryPreferences {
  const DietaryPreferencesModel({
    required super.userId,
    super.dietType,
    super.allergies = const [],
    super.intolerances = const [],
    super.dislikedFoods = const [],
    super.preferredCuisines = const [],
    super.mealsPerDay,
    super.includeSnacks,
    super.updatedAt,
  });

  /// Creates a DietaryPreferencesModel from JSON.
  factory DietaryPreferencesModel.fromJson(Map<String, dynamic> json) {
    return DietaryPreferencesModel(
      userId: json['user_id'] as String,
      dietType: json['diet_type'] as String?,
      allergies: (json['allergies'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      intolerances: (json['intolerances'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      dislikedFoods: (json['disliked_foods'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      preferredCuisines: (json['preferred_cuisines'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      mealsPerDay: json['meals_per_day'] as int?,
      includeSnacks: json['include_snacks'] as bool?,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Converts the model to JSON.
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'diet_type': dietType,
      'allergies': allergies,
      'intolerances': intolerances,
      'disliked_foods': dislikedFoods,
      'preferred_cuisines': preferredCuisines,
      'meals_per_day': mealsPerDay,
      'include_snacks': includeSnacks,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
