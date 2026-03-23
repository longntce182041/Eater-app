class MealLog {
  final String id;
  final String mealName;
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  final String mealType; // breakfast, lunch, dinner, snack
  final DateTime loggedAt;
  final double quantity;
  final String unit; // grams, ml, pieces, etc
  final String? notes;
  final String? imageUrl;

  MealLog({
    required this.id,
    required this.mealName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.mealType,
    required this.loggedAt,
    required this.quantity,
    required this.unit,
    this.notes,
    this.imageUrl,
  });

  // Convert to JSON for API calls
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mealName': mealName,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'mealType': mealType,
      'loggedAt': loggedAt.toIso8601String(),
      'quantity': quantity,
      'unit': unit,
      'notes': notes,
      'imageUrl': imageUrl,
    };
  }

  // Convert from JSON
  factory MealLog.fromJson(Map<String, dynamic> json) {
    return MealLog(
      id: (json['id'] ?? json['_id']).toString(),
      mealName: json['mealName'] as String,
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fats: (json['fats'] as num).toDouble(),
      mealType: json['mealType'] as String,
      loggedAt: DateTime.parse(json['loggedAt'] as String),
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      notes: json['notes'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  // Copy with for updates
  MealLog copyWith({
    String? id,
    String? mealName,
    double? calories,
    double? protein,
    double? carbs,
    double? fats,
    String? mealType,
    DateTime? loggedAt,
    double? quantity,
    String? unit,
    String? notes,
    String? imageUrl,
  }) {
    return MealLog(
      id: id ?? this.id,
      mealName: mealName ?? this.mealName,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fats: fats ?? this.fats,
      mealType: mealType ?? this.mealType,
      loggedAt: loggedAt ?? this.loggedAt,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
