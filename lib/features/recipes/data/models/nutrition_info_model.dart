import '../../domain/entities/nutrition_info.dart';

/// Data model for NutritionInfo.
class NutritionInfoModel extends NutritionInfo {
  const NutritionInfoModel({
    required super.calories,
    required super.protein,
    required super.carbohydrates,
    required super.fat,
    super.fiber,
    super.sugar,
    super.sodium,
    super.cholesterol,
    super.saturatedFat,
    super.transFat,
  });

  /// Creates a NutritionInfoModel from JSON.
  factory NutritionInfoModel.fromJson(Map<String, dynamic> json) {
    return NutritionInfoModel(
      calories: json['calories'] as int,
      protein: (json['protein'] as num).toDouble(),
      carbohydrates: (json['carbohydrates'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      fiber: (json['fiber'] as num?)?.toDouble(),
      sugar: (json['sugar'] as num?)?.toDouble(),
      sodium: (json['sodium'] as num?)?.toDouble(),
      cholesterol: (json['cholesterol'] as num?)?.toDouble(),
      saturatedFat: (json['saturated_fat'] as num?)?.toDouble(),
      transFat: (json['trans_fat'] as num?)?.toDouble(),
    );
  }

  /// Converts the model to JSON.
  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbohydrates': carbohydrates,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
      'cholesterol': cholesterol,
      'saturated_fat': saturatedFat,
      'trans_fat': transFat,
    };
  }
}
