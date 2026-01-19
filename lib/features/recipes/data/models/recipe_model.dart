import '../../domain/entities/recipe.dart';
import 'ingredient_model.dart';
import 'nutrition_info_model.dart';

/// Data model for Recipe.
class RecipeModel extends Recipe {
  const RecipeModel({
    required super.id,
    required super.name,
    super.description,
    super.imageUrl,
    super.categories = const [],
    super.cuisineTypes = const [],
    super.dietaryLabels = const [],
    super.prepTimeMinutes = 0,
    super.cookTimeMinutes = 0,
    super.servings = 1,
    super.difficulty,
    super.ingredients = const [],
    super.instructions = const [],
    super.nutritionPerServing,
    super.rating,
    super.reviewCount,
    super.isFavorite = false,
    super.createdAt,
  });

  /// Creates a RecipeModel from JSON.
  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      cuisineTypes: (json['cuisine_types'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      dietaryLabels: (json['dietary_labels'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      prepTimeMinutes: json['prep_time_minutes'] as int? ?? 0,
      cookTimeMinutes: json['cook_time_minutes'] as int? ?? 0,
      servings: json['servings'] as int? ?? 1,
      difficulty: json['difficulty'] as String?,
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => IngredientModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      instructions: (json['instructions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      nutritionPerServing: json['nutrition_per_serving'] != null
          ? NutritionInfoModel.fromJson(
              json['nutrition_per_serving'] as Map<String, dynamic>,
            )
          : null,
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: json['review_count'] as int?,
      isFavorite: json['is_favorite'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Converts the model to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'categories': categories,
      'cuisine_types': cuisineTypes,
      'dietary_labels': dietaryLabels,
      'prep_time_minutes': prepTimeMinutes,
      'cook_time_minutes': cookTimeMinutes,
      'servings': servings,
      'difficulty': difficulty,
      'ingredients':
          ingredients.map((i) => (i as IngredientModel).toJson()).toList(),
      'instructions': instructions,
      'nutrition_per_serving': nutritionPerServing != null
          ? (nutritionPerServing as NutritionInfoModel).toJson()
          : null,
      'rating': rating,
      'review_count': reviewCount,
      'is_favorite': isFavorite,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
