import 'package:equatable/equatable.dart';

/// Nutrition information entity.
class NutritionInfo extends Equatable {
  final int calories;
  final double protein; // grams
  final double carbohydrates; // grams
  final double fat; // grams
  final double? fiber; // grams
  final double? sugar; // grams
  final double? sodium; // mg
  final double? cholesterol; // mg
  final double? saturatedFat; // grams
  final double? transFat; // grams

  const NutritionInfo({
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    this.fiber,
    this.sugar,
    this.sodium,
    this.cholesterol,
    this.saturatedFat,
    this.transFat,
  });

  @override
  List<Object?> get props => [
        calories,
        protein,
        carbohydrates,
        fat,
        fiber,
        sugar,
        sodium,
        cholesterol,
        saturatedFat,
        transFat,
      ];
}
