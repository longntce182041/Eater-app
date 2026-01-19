import 'package:equatable/equatable.dart';

/// Shopping list item entity.
class ShoppingListItem extends Equatable {
  final String id;
  final String shoppingListId;
  final String name;
  final double quantity;
  final String unit;
  final String? category;
  final String? recipeId;
  final String? recipeName;
  final bool isChecked;
  final String? notes;

  const ShoppingListItem({
    required this.id,
    required this.shoppingListId,
    required this.name,
    required this.quantity,
    required this.unit,
    this.category,
    this.recipeId,
    this.recipeName,
    this.isChecked = false,
    this.notes,
  });

  /// Formatted display string.
  String get displayString {
    return '$quantity $unit $name';
  }

  @override
  List<Object?> get props => [
        id,
        shoppingListId,
        name,
        quantity,
        unit,
        category,
        recipeId,
        recipeName,
        isChecked,
        notes,
      ];
}
