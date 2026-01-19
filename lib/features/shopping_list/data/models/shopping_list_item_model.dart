import '../../domain/entities/shopping_list_item.dart';

/// Data model for ShoppingListItem.
class ShoppingListItemModel extends ShoppingListItem {
  const ShoppingListItemModel({
    required super.id,
    required super.shoppingListId,
    required super.name,
    required super.quantity,
    required super.unit,
    super.category,
    super.recipeId,
    super.recipeName,
    super.isChecked = false,
    super.notes,
  });

  /// Creates a ShoppingListItemModel from JSON.
  factory ShoppingListItemModel.fromJson(Map<String, dynamic> json) {
    return ShoppingListItemModel(
      id: json['id'] as String,
      shoppingListId: json['shopping_list_id'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      category: json['category'] as String?,
      recipeId: json['recipe_id'] as String?,
      recipeName: json['recipe_name'] as String?,
      isChecked: json['is_checked'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }

  /// Converts the model to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopping_list_id': shoppingListId,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'category': category,
      'recipe_id': recipeId,
      'recipe_name': recipeName,
      'is_checked': isChecked,
      'notes': notes,
    };
  }
}
