/// 🛒 GROCERY LIST DOMAIN MODELS
///
/// Data models representing grocery shopping list items
/// Used for local storage, API sync, and UI display
///
/// Models:
/// - GroceryItem: Individual item in grocery list
/// - GroceryStats: Aggregated statistics about list completion

/// 📦 GROCERY ITEM MODEL
///
/// Represents a single item in user's grocery shopping list
/// Can be added manually or automatically from meal plan recipes
/// Tracks purchase status and origin (recipe source)
///
/// Fields:
/// - id: Unique identifier (MongoDB ObjectId or generated)
/// - ingredientId: Reference to ingredient master data
/// - name: Display name of ingredient (e.g., "Tomatoes", "Olive Oil")
/// - quantity: How much to buy (e.g., 2, 1.5, 0.25)
/// - unit: Unit of measurement (e.g., "cups", "lb", "pieces")
/// - isPurchased: Whether user has bought this item
/// - recipeId: Optional reference to source recipe (for tracking)
/// - recipeName: Optional display name of source recipe
/// - addedAt: When item was added to list
///
/// Purchase Workflow:
/// ```
/// 1. User/system adds item with isPurchased = false
/// 2. User taps item in store → toggles isPurchased = true
/// 3. User taps "clear purchased" → removes from list
/// ```
///
/// Consolidation:
/// - When same ingredient (by ID) added multiple times
/// - Quantities combine: 2 cups + 3 cups = 5 cups total
/// - Single item replaces duplicates (no clutter)
///
/// Usage:
/// ```dart
/// final item = GroceryItem(
///   id: '',
///   ingredientId: 'ing_123',
///   name: 'Tomatoes',
///   quantity: 4,
///   unit: 'cups',
///   recipeId: 'recipe_456',
///   recipeName: 'Pasta Sauce',
/// );
/// ```
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

  /// 🔄 Deserialize from JSON (for local storage)
  ///
  /// Reconstructs GroceryItem from stored JSON
  /// Used when reading from local database/cache
  /// Handles missing fields gracefully with defaults
  ///
  /// JSON Structure:
  /// ```json
  /// {
  ///   "id": "item_001",
  ///   "ingredientId": "ing_123",
  ///   "name": "Tomatoes",
  ///   "quantity": 4.0,
  ///   "unit": "cups",
  ///   "isPurchased": false,
  ///   "recipeId": "recipe_456",
  ///   "recipeName": "Pasta Sauce",
  ///   "addedAt": "2024-03-15T10:30:00.000Z"
  /// }
  /// ```
  ///
  /// Usage:
  /// ```dart
  /// final json = jsonDecode(storedJson);
  /// final item = GroceryItem.fromJson(json);
  /// ```
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

  /// 💾 Serialize to JSON (for local storage)
  ///
  /// Converts GroceryItem to JSON for storage
  /// Used when caching locally or sending to API
  /// Omits null fields (optional fields not included if null)
  ///
  /// Output Structure:
  /// ```json
  /// {
  ///   "id": "item_001",
  ///   "ingredientId": "ing_123",
  ///   "name": "Tomatoes",
  ///   "quantity": 4.0,
  ///   "unit": "cups",
  ///   "isPurchased": false,
  ///   "recipeId": "recipe_456",
  ///   "recipeName": "Pasta Sauce",
  ///   "addedAt": "2024-03-15T10:30:00.000Z"
  /// }
  /// ```
  ///
  /// Usage:
  /// ```dart
  /// final item = GroceryItem(...);
  /// final json = item.toJson();
  /// final stored = jsonEncode(json);
  /// ```
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

  /// ✏️ Create modified copy with specified fields changed
  ///
  /// Immutable pattern for state management
  /// Used when updating item (e.g., marking purchased)
  /// Returns new instance without modifying original
  ///
  /// Common use cases:
  /// ```dart
  /// // Toggle purchased status
  /// final purchased = item.copyWith(isPurchased: true);
  ///
  /// // Update quantity (consolidation)
  /// final consolidated = item.copyWith(
  ///   quantity: item.quantity + newItem.quantity,
  /// );
  ///
  /// // Clear recipe reference
  /// final cleared = item.copyWith(recipeId: null);
  /// ```
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

  /// 📊 Display-friendly quantity with unit
  ///
  /// Formats quantity and unit for UI display
  /// Examples:
  /// - "2.0 cups"
  /// - "1.5 lb"
  /// - "3.0 pieces"
  ///
  /// Usage:
  /// ```dart
  /// Text(item.displayQuantity) // "2.0 cups"
  /// ```
  String get displayQuantity => '$quantity $unit';

  /// 🔍 Equality operator for comparison
  ///
  /// Two items are equal if they have same ID
  /// Used for list operations (finding, removing)
  ///
  /// Note: This is ID-based equality, not content-based
  /// So two items with same details but different IDs are not equal
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroceryItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  /// 🆔 Hash code for Set/Map operations
  ///
  /// Must match equality operator
  /// Based on ID for consistent behavior
  @override
  int get hashCode => id.hashCode;
}

/// 📊 GROCERY LIST STATISTICS MODEL
///
/// Aggregated metrics about grocery list completion
/// Used for progress tracking and UI visualization
///
/// Fields:
/// - totalItems: Total count of items in list
/// - purchasedItems: Count of items marked as purchased
/// - pendingItems: Count of items not yet purchased
///
/// Computed Fields:
/// - completionPercentage: Purchased / Total × 100
/// - isComplete: Whether all items are purchased
///
/// Usage:
/// ```dart
/// final stats = groceryListState.stats;
/// print('${stats.completionPercentage}% done');
/// if (stats.isComplete) {
///   print('All items purchased! 🎉');
/// }
/// ```
class GroceryStats {
  final int totalItems;
  final int purchasedItems;
  final int pendingItems;

  GroceryStats({
    required this.totalItems,
    required this.purchasedItems,
    required this.pendingItems,
  });

  /// 📈 Calculate completion percentage
  ///
  /// Formula: (purchasedItems / totalItems) × 100
  /// Returns 0 if list is empty (avoids division by zero)
  ///
  /// Examples:
  /// - 0 / 10 items = 0%
  /// - 5 / 10 items = 50%
  /// - 10 / 10 items = 100%
  ///
  /// Usage:
  /// ```dart
  /// final percent = stats.completionPercentage;
  /// LinearProgressIndicator(value: percent / 100);
  /// ```
  double get completionPercentage =>
      totalItems > 0 ? (purchasedItems / totalItems) * 100 : 0;

  /// ✅ Check if all items are purchased
  ///
  /// Returns true only when:
  /// 1. List has at least 1 item
  /// 2. ALL items are marked purchased
  ///
  /// Useful for UI feedback:
  /// ```dart
  /// if (stats.isComplete) {
  ///   showCompletionAnimation();
  /// }
  /// ```
  bool get isComplete => totalItems > 0 && purchasedItems == totalItems;
}
