import '../../domain/entities/ingredient.dart';

/// Data model for Ingredient.
class IngredientModel extends Ingredient {
  const IngredientModel({
    required super.id,
    required super.name,
    required super.quantity,
    required super.unit,
    super.notes,
    super.isOptional = false,
  });

  /// Creates an IngredientModel from JSON.
  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    return IngredientModel(
      id: json['id'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      notes: json['notes'] as String?,
      isOptional: json['is_optional'] as bool? ?? false,
    );
  }

  /// Converts the model to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'notes': notes,
      'is_optional': isOptional,
    };
  }
}
