import 'package:equatable/equatable.dart';

/// Dietary preferences entity.
class DietaryPreferences extends Equatable {
  final String userId;
  final String? dietType; // e.g., vegetarian, vegan, keto, paleo
  final List<String> allergies;
  final List<String> intolerances;
  final List<String> dislikedFoods;
  final List<String> preferredCuisines;
  final int? mealsPerDay;
  final bool? includeSnacks;
  final DateTime? updatedAt;

  const DietaryPreferences({
    required this.userId,
    this.dietType,
    this.allergies = const [],
    this.intolerances = const [],
    this.dislikedFoods = const [],
    this.preferredCuisines = const [],
    this.mealsPerDay,
    this.includeSnacks,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        userId,
        dietType,
        allergies,
        intolerances,
        dislikedFoods,
        preferredCuisines,
        mealsPerDay,
        includeSnacks,
        updatedAt,
      ];
}
