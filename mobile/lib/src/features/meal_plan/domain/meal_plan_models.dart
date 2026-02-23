class MealPlanModel {
  final String id;
  final int days;
  final double? targetCalories;
  final double? actualCalories;
  final String? status;
  final bool aiGenerated;
  final DateTime? date;

  MealPlanModel({
    required this.id,
    required this.days,
    required this.aiGenerated,
    this.targetCalories,
    this.actualCalories,
    this.status,
    this.date,
  });

  factory MealPlanModel.fromJson(Map<String, dynamic> json) {
    return MealPlanModel(
      id: json['_id']?.toString() ?? '',
      days: (json['days'] as num?)?.toInt() ?? 1,
      targetCalories: (json['targetCalories'] as num?)?.toDouble(),
      actualCalories: (json['actualCalories'] as num?)?.toDouble(),
      status: json['status']?.toString(),
      aiGenerated: json['aiGenerated'] == true,
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString())
          : null,
    );
  }
}

class MealPlanItemModel {
  final String id;
  final String mealType;
  final int servings;
  final double calories;
  final double protein;
  final double carbohydrates;
  final double fat;
  final int dayIndex;
  final String? recipeName;
  final String? recipeImageUrl;

  MealPlanItemModel({
    required this.id,
    required this.mealType,
    required this.servings,
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    required this.dayIndex,
    this.recipeName,
    this.recipeImageUrl,
  });

  factory MealPlanItemModel.fromJson(Map<String, dynamic> json) {
    final recipe = json['recipeId'] is Map<String, dynamic>
        ? json['recipeId'] as Map<String, dynamic>
        : null;

    return MealPlanItemModel(
      id: json['_id']?.toString() ?? '',
      mealType: json['mealType']?.toString() ?? 'snack',
      servings: (json['servings'] as num?)?.toInt() ?? 1,
      calories: (json['calories'] as num?)?.toDouble() ?? 0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0,
      carbohydrates: (json['carbohydrates'] as num?)?.toDouble() ?? 0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0,
      dayIndex: (json['dayIndex'] as num?)?.toInt() ?? 0,
      recipeName: recipe?['name']?.toString(),
      recipeImageUrl: recipe?['imageUrl']?.toString(),
    );
  }
}

class MealPlanSummary {
  final int totalMeals;
  final int days;
  final double avgCaloriesPerDay;

  MealPlanSummary({
    required this.totalMeals,
    required this.days,
    required this.avgCaloriesPerDay,
  });

  factory MealPlanSummary.fromJson(Map<String, dynamic> json) {
    return MealPlanSummary(
      totalMeals: (json['totalMeals'] as num?)?.toInt() ?? 0,
      days: (json['days'] as num?)?.toInt() ?? 1,
      avgCaloriesPerDay: (json['avgCaloriesPerDay'] as num?)?.toDouble() ?? 0,
    );
  }
}

class MealPlanGenerationResult {
  final MealPlanModel mealPlan;
  final List<MealPlanItemModel> items;
  final MealPlanSummary? summary;

  MealPlanGenerationResult({
    required this.mealPlan,
    required this.items,
    this.summary,
  });

  factory MealPlanGenerationResult.fromJson(Map<String, dynamic> json) {
    final itemsJson = (json['items'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();

    return MealPlanGenerationResult(
      mealPlan: MealPlanModel.fromJson(
        (json['mealPlan'] as Map<String, dynamic>?) ?? {},
      ),
      items: itemsJson.map(MealPlanItemModel.fromJson).toList(),
      summary: json['summary'] is Map<String, dynamic>
          ? MealPlanSummary.fromJson(json['summary'] as Map<String, dynamic>)
          : null,
    );
  }
}
