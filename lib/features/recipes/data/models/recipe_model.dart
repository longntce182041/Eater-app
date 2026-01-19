import '../../domain/entities/recipe.dart';

class RecipeModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int prepTime;
  final int cookTime;
  final int servings;
  final List<String> ingredients;
  final List<String> instructions;
  final int calories;
  final Map<String, double> macros;
  final List<String> tags;
  final String cuisine;
  final String difficulty;

  RecipeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.prepTime,
    required this.cookTime,
    required this.servings,
    required this.ingredients,
    required this.instructions,
    required this.calories,
    required this.macros,
    required this.tags,
    required this.cuisine,
    required this.difficulty,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String,
      prepTime: json['prep_time'] as int,
      cookTime: json['cook_time'] as int,
      servings: json['servings'] as int,
      ingredients: (json['ingredients'] as List).cast<String>(),
      instructions: (json['instructions'] as List).cast<String>(),
      calories: json['calories'] as int,
      macros: Map<String, double>.from(json['macros']),
      tags: (json['tags'] as List).cast<String>(),
      cuisine: json['cuisine'] as String,
      difficulty: json['difficulty'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'prep_time': prepTime,
      'cook_time': cookTime,
      'servings': servings,
      'ingredients': ingredients,
      'instructions': instructions,
      'calories': calories,
      'macros': macros,
      'tags': tags,
      'cuisine': cuisine,
      'difficulty': difficulty,
    };
  }

  Recipe toEntity() {
    return Recipe(
      id: id,
      name: name,
      description: description,
      imageUrl: imageUrl,
      prepTime: prepTime,
      cookTime: cookTime,
      servings: servings,
      ingredients: ingredients,
      instructions: instructions,
      calories: calories,
      macros: macros,
      tags: tags,
      cuisine: cuisine,
      difficulty: difficulty,
    );
  }
}
