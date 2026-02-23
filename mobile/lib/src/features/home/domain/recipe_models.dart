class Recipe {
  final String id;
  final String name;
  final String description;
  final int cookingTime;
  final int baseServings;
  final String status;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.cookingTime,
    required this.baseServings,
    required this.status,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      cookingTime: (json['cookingTime'] as num).toInt(),
      baseServings: (json['baseServings'] as num).toInt(),
      status: json['status'] as String,
      imageUrl: json['imageUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'cookingTime': cookingTime,
      'baseServings': baseServings,
      'status': status,
      'imageUrl': imageUrl,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  // Helper to get display cooking time
  String get cookingTimeDisplay {
    if (cookingTime < 60) {
      return '$cookingTime min';
    } else {
      final hours = cookingTime ~/ 60;
      final minutes = cookingTime % 60;
      if (minutes == 0) {
        return '$hours hr';
      }
      return '$hours hr $minutes min';
    }
  }

  // Helper to get placeholder image if imageUrl is null
  String get displayImageUrl {
    return imageUrl ??
        'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400';
  }
}

class RecipeListResponse {
  final List<Recipe> recipes;
  final int total;
  final int page;
  final int totalPages;

  RecipeListResponse({
    required this.recipes,
    required this.total,
    required this.page,
    required this.totalPages,
  });

  factory RecipeListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return RecipeListResponse(
      recipes: (data['recipes'] as List)
          .map((e) => Recipe.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (data['total'] as num).toInt(),
      page: (data['page'] as num).toInt(),
      totalPages: (data['totalPages'] as num).toInt(),
    );
  }

  bool get hasMore => page < totalPages;
}
