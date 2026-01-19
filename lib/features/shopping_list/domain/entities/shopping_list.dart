import 'package:equatable/equatable.dart';

import 'shopping_list_item.dart';

/// Shopping list entity.
class ShoppingList extends Equatable {
  final String id;
  final String userId;
  final String? name;
  final List<ShoppingListItem> items;
  final bool isCompleted;
  final DateTime? mealPlanDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ShoppingList({
    required this.id,
    required this.userId,
    this.name,
    this.items = const [],
    this.isCompleted = false,
    this.mealPlanDate,
    this.createdAt,
    this.updatedAt,
  });

  /// Count of completed items.
  int get completedCount => items.where((item) => item.isChecked).length;

  /// Count of remaining items.
  int get remainingCount => items.length - completedCount;

  /// Progress percentage.
  double get progress =>
      items.isEmpty ? 0 : completedCount / items.length;

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        items,
        isCompleted,
        mealPlanDate,
        createdAt,
        updatedAt,
      ];
}
