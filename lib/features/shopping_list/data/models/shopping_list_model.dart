import '../../domain/entities/shopping_list.dart';
import 'shopping_list_item_model.dart';

/// Data model for ShoppingList.
class ShoppingListModel extends ShoppingList {
  const ShoppingListModel({
    required super.id,
    required super.userId,
    super.name,
    super.items = const [],
    super.isCompleted = false,
    super.mealPlanDate,
    super.createdAt,
    super.updatedAt,
  });

  /// Creates a ShoppingListModel from JSON.
  factory ShoppingListModel.fromJson(Map<String, dynamic> json) {
    return ShoppingListModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map(
                (e) => ShoppingListItemModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      isCompleted: json['is_completed'] as bool? ?? false,
      mealPlanDate: json['meal_plan_date'] != null
          ? DateTime.parse(json['meal_plan_date'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Converts the model to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'items': items
          .map((i) => (i as ShoppingListItemModel).toJson())
          .toList(),
      'is_completed': isCompleted,
      'meal_plan_date': mealPlanDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
