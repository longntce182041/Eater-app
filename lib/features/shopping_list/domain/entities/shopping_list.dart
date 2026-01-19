// Shopping List Entity
class ShoppingList {
  final String id;
  final String userId;
  final String name;
  final DateTime createdAt;
  final List<ShoppingListItem> items;
  final bool isCompleted;

  ShoppingList({
    required this.id,
    required this.userId,
    required this.name,
    required this.createdAt,
    required this.items,
    required this.isCompleted,
  });
}

class ShoppingListItem {
  final String id;
  final String name;
  final String category; // produce, dairy, meat, pantry, etc.
  final double quantity;
  final String unit;
  final bool isPurchased;
  final String? notes;

  ShoppingListItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.isPurchased,
    this.notes,
  });
}
