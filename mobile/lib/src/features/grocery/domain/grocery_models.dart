// Grocery List Domain Models
// Represents items in the user's grocery shopping list

class GroceryItem {
  final String id; // Unique identifier for the grocery item
  final String ingredientId; // Reference to ingredient
  final String name;
  final double quantity;
  final String unit;
  final bool isPurchased;
  final String? recipeId; // Optional: track which recipe it came from
  final String? recipeName; // Optional: for display
  final DateTime addedAt;

  GroceryItem({
    required this.id,
    required this.ingredientId,
    required this.name,
    required this.quantity,
    required this.unit,
    this.isPurchased = false,
    this.recipeId,
    this.recipeName,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  /// Create from JSON (for local storage)
  factory GroceryItem.fromJson(Map<String, dynamic> json) {
    return GroceryItem(
      id: json['id']?.toString() ?? '',
      ingredientId: json['ingredientId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit']?.toString() ?? '',
      isPurchased: json['isPurchased'] as bool? ?? false,
      recipeId: json['recipeId']?.toString(),
      recipeName: json['recipeName']?.toString(),
      addedAt: json['addedAt'] != null
          ? DateTime.parse(json['addedAt'] as String)
          : DateTime.now(),
    );
  }

  /// Convert to JSON (for local storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ingredientId': ingredientId,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'isPurchased': isPurchased,
      if (recipeId != null) 'recipeId': recipeId,
      if (recipeName != null) 'recipeName': recipeName,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  /// Copy with method for state updates
  GroceryItem copyWith({
    String? id,
    String? ingredientId,
    String? name,
    double? quantity,
    String? unit,
    bool? isPurchased,
    String? recipeId,
    String? recipeName,
    DateTime? addedAt,
  }) {
    return GroceryItem(
      id: id ?? this.id,
      ingredientId: ingredientId ?? this.ingredientId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      isPurchased: isPurchased ?? this.isPurchased,
      recipeId: recipeId ?? this.recipeId,
      recipeName: recipeName ?? this.recipeName,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  /// Display quantity with unit
  String get displayQuantity => '$quantity $unit';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroceryItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Stats for grocery list
class GroceryStats {
  final int totalItems;
  final int purchasedItems;
  final int pendingItems;

  GroceryStats({
    required this.totalItems,
    required this.purchasedItems,
    required this.pendingItems,
  });

  double get completionPercentage =>
      totalItems > 0 ? (purchasedItems / totalItems) * 100 : 0;

  bool get isComplete => totalItems > 0 && purchasedItems == totalItems;
}
