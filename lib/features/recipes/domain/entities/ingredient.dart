import 'package:equatable/equatable.dart';

/// Ingredient entity for recipes.
class Ingredient extends Equatable {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final String? notes;
  final bool isOptional;

  const Ingredient({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    this.notes,
    this.isOptional = false,
  });

  /// Formatted display string for the ingredient.
  String get displayString {
    final optionalText = isOptional ? ' (optional)' : '';
    final notesText = notes != null ? ' - $notes' : '';
    return '$quantity $unit $name$optionalText$notesText';
  }

  @override
  List<Object?> get props => [id, name, quantity, unit, notes, isOptional];
}
