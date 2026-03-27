class MealImageScanResult {
  final String mealName;
  final double confidence;
  final List<MealImageScanIngredient> ingredients;
  final MealImageScanTotals totals;
  final String note;

  const MealImageScanResult({
    required this.mealName,
    required this.confidence,
    required this.ingredients,
    required this.totals,
    required this.note,
  });

  factory MealImageScanResult.fromJson(Map<String, dynamic> json) {
    final rawIngredients = (json['ingredients'] as List?) ?? const [];
    return MealImageScanResult(
      mealName: (json['meal_name'] as String?) ?? 'Unknown meal',
      confidence: _toDouble(json['confidence']),
      ingredients: rawIngredients
          .whereType<Map>()
          .map((e) =>
              MealImageScanIngredient.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      totals: MealImageScanTotals.fromJson(
        Map<String, dynamic>.from((json['totals'] as Map?) ?? const {}),
      ),
      note: (json['note'] as String?) ??
          'Nutrition values are estimated from image analysis and local ingredient database.',
    );
  }
}

class MealImageScanIngredient {
  final String inputName;
  final String? matchedName;
  final double? estimatedAmount;
  final String? estimatedUnit;
  final double? convertedAmount;
  final String? convertedUnit;
  final String? dbUnit;
  final MealImageScanNutrition nutrition;
  final String status;

  const MealImageScanIngredient({
    required this.inputName,
    required this.matchedName,
    required this.estimatedAmount,
    required this.estimatedUnit,
    required this.convertedAmount,
    required this.convertedUnit,
    required this.dbUnit,
    required this.nutrition,
    required this.status,
  });

  factory MealImageScanIngredient.fromJson(Map<String, dynamic> json) {
    return MealImageScanIngredient(
      inputName: (json['input_name'] as String?) ?? '',
      matchedName: json['matched_name'] as String?,
      estimatedAmount: _toNullableDouble(json['estimated_amount']),
      estimatedUnit: json['estimated_unit'] as String?,
      convertedAmount: _toNullableDouble(json['converted_amount']),
      convertedUnit: json['converted_unit'] as String?,
      dbUnit: json['db_unit'] as String?,
      nutrition: MealImageScanNutrition.fromJson(
        Map<String, dynamic>.from((json['nutrition'] as Map?) ?? const {}),
      ),
      status: (json['status'] as String?) ?? 'unknown',
    );
  }
}

class MealImageScanNutrition {
  final double kcal;
  final double protein;
  final double carbs;
  final double fats;

  const MealImageScanNutrition({
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  factory MealImageScanNutrition.fromJson(Map<String, dynamic> json) {
    return MealImageScanNutrition(
      kcal: _toDouble(json['kcal']),
      protein: _toDouble(json['protein']),
      carbs: _toDouble(json['carbs']),
      fats: _toDouble(json['fats']),
    );
  }
}

class MealImageScanTotals {
  final double kcal;
  final double protein;
  final double carbs;
  final double fats;

  const MealImageScanTotals({
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  factory MealImageScanTotals.fromJson(Map<String, dynamic> json) {
    return MealImageScanTotals(
      kcal: _toDouble(json['kcal']),
      protein: _toDouble(json['protein']),
      carbs: _toDouble(json['carbs']),
      fats: _toDouble(json['fats']),
    );
  }
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

double? _toNullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}
