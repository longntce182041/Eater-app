import 'package:equatable/equatable.dart';

import 'ingredient.dart';
import 'nutrition_info.dart';

/// Recipe entity.
class Recipe extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final List<String> categories;
  final List<String> cuisineTypes;
  final List<String> dietaryLabels;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int servings;
  final String? difficulty;
  final List<Ingredient> ingredients;
  final List<String> instructions;
  final NutritionInfo? nutritionPerServing;
  final double? rating;
  final int? reviewCount;
  final bool isFavorite;
  final DateTime? createdAt;

  const Recipe({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.categories = const [],
    this.cuisineTypes = const [],
    this.dietaryLabels = const [],
    this.prepTimeMinutes = 0,
    this.cookTimeMinutes = 0,
    this.servings = 1,
    this.difficulty,
    this.ingredients = const [],
    this.instructions = const [],
    this.nutritionPerServing,
    this.rating,
    this.reviewCount,
    this.isFavorite = false,
    this.createdAt,
  });

  /// Total time in minutes.
  int get totalTimeMinutes => prepTimeMinutes + cookTimeMinutes;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        imageUrl,
        categories,
        cuisineTypes,
        dietaryLabels,
        prepTimeMinutes,
        cookTimeMinutes,
        servings,
        difficulty,
        ingredients,
        instructions,
        nutritionPerServing,
        rating,
        reviewCount,
        isFavorite,
        createdAt,
      ];
}
