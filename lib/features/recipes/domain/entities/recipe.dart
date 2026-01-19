// Recipe Entity
class Recipe {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int prepTime; // in minutes
  final int cookTime; // in minutes
  final int servings;
  final List<String> ingredients;
  final List<String> instructions;
  final int calories;
  final Map<String, double> macros;
  final List<String> tags;
  final String cuisine;
  final String difficulty;

  Recipe({
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
}
