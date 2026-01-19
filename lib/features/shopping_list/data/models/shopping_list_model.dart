import '../../domain/entities/shopping_list.dart';

class ShoppingListModel {
  final String id;
  final String userId;
  final String name;
  final DateTime createdAt;
  final List<ShoppingListItemModel> items;
  final bool isCompleted;

  ShoppingListModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.createdAt,
    required this.items,
    required this.isCompleted,
  });

  factory ShoppingListModel.fromJson(Map<String, dynamic> json) {
    return ShoppingListModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      items: (json['items'] as List).map((e) => ShoppingListItemModel.fromJson(e)).toList(),
      isCompleted: json['is_completed'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'items': items.map((e) => e.toJson()).toList(),
      'is_completed': isCompleted,
    };
  }

  ShoppingList toEntity() {
    return ShoppingList(
      id: id,
      userId: userId,
      name: name,
      createdAt: createdAt,
      items: items.map((e) => e.toEntity()).toList(),
      isCompleted: isCompleted,
    );
  }
}

class ShoppingListItemModel {
  final String id;
  final String name;
  final String category;
  final double quantity;
  final String unit;
  final bool isPurchased;
  final String? notes;

  ShoppingListItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.isPurchased,
    this.notes,
  });

  factory ShoppingListItemModel.fromJson(Map<String, dynamic> json) {
    return ShoppingListItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      isPurchased: json['is_purchased'] as bool,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'is_purchased': isPurchased,
      'notes': notes,
    };
  }

  ShoppingListItem toEntity() {
    return ShoppingListItem(
      id: id,
      name: name,
      category: category,
      quantity: quantity,
      unit: unit,
      isPurchased: isPurchased,
      notes: notes,
    );
  }
}
