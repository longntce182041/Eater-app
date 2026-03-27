class Recipe {
  final String id;
  final String name;
  final String description;
  final int cookingTime;
  final int baseServings;
  final String? status;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isFavorited;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.cookingTime,
    required this.baseServings,
    this.status,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
    this.isFavorited = false,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      cookingTime: (json['cookingTime'] as num).toInt(),
      baseServings: (json['baseServings'] as num).toInt(),
      status: json['status'] as String?,
      imageUrl: json['imageUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isFavorited: json['isFavorited'] == true,
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
      'isFavorited': isFavorited,
    };
  }

  // Copy with method for state updates
  Recipe copyWith({
    String? id,
    String? name,
    String? description,
    int? cookingTime,
    int? baseServings,
    String? status,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorited,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      cookingTime: cookingTime ?? this.cookingTime,
      baseServings: baseServings ?? this.baseServings,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorited: isFavorited ?? this.isFavorited,
    );
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

class NumericRange {
  final double min;
  final double max;

  NumericRange({required this.min, required this.max});

  factory NumericRange.fromJson(Map<String, dynamic> json) {
    return NumericRange(
      min: (json['min'] as num?)?.toDouble() ?? 0,
      max: (json['max'] as num?)?.toDouble() ?? 0,
    );
  }
}

class RecipeDietOption {
  final String id;
  final String name;
  final int recipeCount;

  RecipeDietOption({
    required this.id,
    required this.name,
    required this.recipeCount,
  });

  factory RecipeDietOption.fromJson(Map<String, dynamic> json) {
    return RecipeDietOption(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      recipeCount: (json['recipeCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class RecipeIngredientOption {
  final String id;
  final String name;
  final int recipeCount;

  RecipeIngredientOption({
    required this.id,
    required this.name,
    required this.recipeCount,
  });

  factory RecipeIngredientOption.fromJson(Map<String, dynamic> json) {
    return RecipeIngredientOption(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      recipeCount: (json['recipeCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class RecipeFilterOptions {
  final NumericRange calories;
  final NumericRange protein;
  final NumericRange fat;
  final NumericRange carbohydrates;
  final int minCookingTime;
  final int maxCookingTime;
  final List<int> suggestedCookingTimes;
  final List<RecipeDietOption> dietTypes;
  final List<RecipeIngredientOption> ingredients;

  RecipeFilterOptions({
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbohydrates,
    required this.minCookingTime,
    required this.maxCookingTime,
    required this.suggestedCookingTimes,
    required this.dietTypes,
    required this.ingredients,
  });

  factory RecipeFilterOptions.fromJson(Map<String, dynamic> json) {
    final cooking =
        (json['cookingTime'] as Map<String, dynamic>? ?? <String, dynamic>{});
    final nutrition = (json['nutritionRanges'] as Map<String, dynamic>? ??
        <String, dynamic>{});

    return RecipeFilterOptions(
      calories: NumericRange.fromJson(
        (nutrition['calories'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      ),
      protein: NumericRange.fromJson(
        (nutrition['protein'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      ),
      fat: NumericRange.fromJson(
        (nutrition['fat'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      ),
      carbohydrates: NumericRange.fromJson(
        (nutrition['carbohydrates'] as Map<String, dynamic>? ??
            <String, dynamic>{}),
      ),
      minCookingTime: (cooking['min'] as num?)?.toInt() ?? 0,
      maxCookingTime: (cooking['max'] as num?)?.toInt() ?? 0,
      suggestedCookingTimes: ((cooking['suggestedMaxOptions'] as List?) ?? [])
          .map((item) => (item as num).toInt())
          .toList(),
      dietTypes: ((json['dietTypes'] as List?) ?? [])
          .map(
              (item) => RecipeDietOption.fromJson(item as Map<String, dynamic>))
          .toList(),
      ingredients: ((json['ingredients'] as List?) ?? [])
          .map(
            (item) => RecipeIngredientOption.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}

class RecipeNutrition {
  final String id;
  final String recipeId;
  final double calories;
  final double protein;
  final double fat;
  final double carbohydrates;

  RecipeNutrition({
    required this.id,
    required this.recipeId,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbohydrates,
  });

  factory RecipeNutrition.fromJson(Map<String, dynamic> json) {
    return RecipeNutrition(
      id: json['_id'] as String,
      recipeId: json['recipeId'] is Map
          ? (json['recipeId'] as Map<String, dynamic>)['_id'] as String
          : json['recipeId'] as String,
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      carbohydrates: (json['carbohydrates'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'recipeId': recipeId,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbohydrates': carbohydrates,
    };
  }
}

class FavoriteRecipe {
  final String favoriteId;
  final Recipe recipe;
  final DateTime favoritedAt;

  FavoriteRecipe({
    required this.favoriteId,
    required this.recipe,
    required this.favoritedAt,
  });

  factory FavoriteRecipe.fromJson(Map<String, dynamic> json) {
    return FavoriteRecipe(
      favoriteId: json['favoriteId'] as String,
      recipe: Recipe.fromJson(json['recipe'] as Map<String, dynamic>),
      favoritedAt: DateTime.parse(json['favoritedAt'] as String),
    );
  }
}

class FavoriteRecipesResponse {
  final List<FavoriteRecipe> favorites;
  final int total;
  final int page;
  final int totalPages;
  final bool hasMore;

  FavoriteRecipesResponse({
    required this.favorites,
    required this.total,
    required this.page,
    required this.totalPages,
    required this.hasMore,
  });

  factory FavoriteRecipesResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final pagination = data['pagination'] as Map<String, dynamic>;

    return FavoriteRecipesResponse(
      favorites: (data['recipes'] as List)
          .map((e) => FavoriteRecipe.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (pagination['total'] as num).toInt(),
      page: (pagination['page'] as num).toInt(),
      totalPages: (pagination['totalPages'] as num).toInt(),
      hasMore: pagination['hasMore'] == true,
    );
  }
}

// Recipe Review Models
class RecipeReview {
  final String? reviewId;
  final int rating;
  final String comment;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RecipeReview({
    this.reviewId,
    required this.rating,
    this.comment = '',
    this.createdAt,
    this.updatedAt,
  });

  factory RecipeReview.fromJson(Map<String, dynamic> json) {
    return RecipeReview(
      reviewId: json['reviewId'] as String?,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String? ?? '',
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
      'rating': rating,
      'comment': comment,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  RecipeReview copyWith({
    String? reviewId,
    int? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecipeReview(
      reviewId: reviewId ?? this.reviewId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ReviewAuthor {
  final String userId;
  final String name;
  final String? email;
  final String? profileImage;

  ReviewAuthor({
    required this.userId,
    required this.name,
    this.email,
    this.profileImage,
  });

  factory ReviewAuthor.fromJson(Map<String, dynamic> json) {
    final rawEmail = json['email'];
    final fallbackName = rawEmail is String && rawEmail.contains('@')
        ? rawEmail.split('@').first
        : 'User';

    return ReviewAuthor(
      userId: (json['_id'] ?? '').toString(),
      name: (json['name'] as String?)?.trim().isNotEmpty == true
          ? json['name'] as String
          : fallbackName,
      email: rawEmail as String?,
      profileImage: json['profileImage'] as String?,
    );
  }
}

class RecipeReviewDetail {
  final String reviewId;
  final int rating;
  final String comment;
  final ReviewAuthor author;
  final DateTime createdAt;
  final DateTime? updatedAt;

  RecipeReviewDetail({
    required this.reviewId,
    required this.rating,
    required this.comment,
    required this.author,
    required this.createdAt,
    this.updatedAt,
  });

  factory RecipeReviewDetail.fromJson(Map<String, dynamic> json) {
    final authorJson = json['userId'];

    return RecipeReviewDetail(
      reviewId: (json['_id'] ?? '').toString(),
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String? ?? '',
      author: authorJson is Map<String, dynamic>
          ? ReviewAuthor.fromJson(authorJson)
          : ReviewAuthor(userId: '', name: 'User'),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}

class RatingStats {
  final double avgRating;
  final int totalReviews;
  final Map<int, double> ratingDistribution; // 5->20%, 4->30%, etc

  RatingStats({
    required this.avgRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });

  factory RatingStats.fromJson(Map<String, dynamic> json) {
    final dist = json['ratingDistribution'] as Map<String, dynamic>?;
    final distribution = <int, double>{};

    if (dist != null) {
      dist.forEach((key, value) {
        distribution[int.parse(key)] = (value as num).toDouble();
      });
    }

    return RatingStats(
      avgRating: (json['avgRating'] as num).toDouble(),
      totalReviews: (json['totalReviews'] as num).toInt(),
      ratingDistribution: distribution,
    );
  }
}

class RecipeReviewsResponse {
  final List<RecipeReviewDetail> reviews;
  final int total;
  final int page;
  final int totalPages;
  final bool hasMore;
  final RatingStats stats;

  RecipeReviewsResponse({
    required this.reviews,
    required this.total,
    required this.page,
    required this.totalPages,
    required this.hasMore,
    required this.stats,
  });

  factory RecipeReviewsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final pagination = data['pagination'] as Map<String, dynamic>;
    final statsData = data['stats'] as Map<String, dynamic>;

    return RecipeReviewsResponse(
      reviews: (data['reviews'] as List)
          .map((e) => RecipeReviewDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (pagination['total'] as num).toInt(),
      page: (pagination['page'] as num).toInt(),
      totalPages: (pagination['totalPages'] as num).toInt(),
      hasMore: pagination['hasMore'] == true,
      stats: RatingStats.fromJson(statsData),
    );
  }
}

class UserReviewsResponse {
  final List<UserReviewItem> reviews;
  final int total;
  final int page;
  final int totalPages;
  final bool hasMore;

  UserReviewsResponse({
    required this.reviews,
    required this.total,
    required this.page,
    required this.totalPages,
    required this.hasMore,
  });

  factory UserReviewsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final pagination = data['pagination'] as Map<String, dynamic>;

    return UserReviewsResponse(
      reviews: (data['reviews'] as List)
          .map((e) => UserReviewItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (pagination['total'] as num).toInt(),
      page: (pagination['page'] as num).toInt(),
      totalPages: (pagination['totalPages'] as num).toInt(),
      hasMore: pagination['hasMore'] == true,
    );
  }
}

class UserReviewItem {
  final String reviewId;
  final int rating;
  final String comment;
  final Recipe recipe;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserReviewItem({
    required this.reviewId,
    required this.rating,
    required this.comment,
    required this.recipe,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserReviewItem.fromJson(Map<String, dynamic> json) {
    return UserReviewItem(
      reviewId: json['reviewId'] as String,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String? ?? '',
      recipe: Recipe.fromJson(json['recipe'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}

/// Ingredient Model
class Ingredient {
  final String id;
  final String name;
  final String? imageUrl;
  final double caloriesPerUnit;
  final double? protein;
  final double? carbs;
  final double? fats;
  final String? description;
  final String unit;

  Ingredient({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.caloriesPerUnit,
    this.protein,
    this.carbs,
    this.fats,
    this.description,
    required this.unit,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['_id'] as String,
      name: json['name'] as String,
      imageUrl: json['ImageUrl'] as String?,
      caloriesPerUnit: (json['calories_per_unit'] as num).toDouble(),
      protein: (json['protein'] as num?)?.toDouble(),
      carbs: (json['carbs'] as num?)?.toDouble(),
      fats: (json['fats'] as num?)?.toDouble(),
      description: json['description'] as String?,
      unit: json['unit'] as String,
    );
  }
}

/// Recipe Ingredient (junction model)
class RecipeIngredient {
  final String recipeId;
  final Ingredient ingredient;
  final String baseQuantity;
  final String unit;

  RecipeIngredient({
    required this.recipeId,
    required this.ingredient,
    required this.baseQuantity,
    required this.unit,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      recipeId: json['recipeId'] is String
          ? json['recipeId'] as String
          : (json['recipeId'] as Map<String, dynamic>)['_id'] as String,
      ingredient: Ingredient.fromJson(
        json['ingredientId'] as Map<String, dynamic>,
      ),
      baseQuantity: json['base_quantity'] as String,
      unit: json['unit'] as String,
    );
  }

  /// Convert to display string
  String get displayText => '$baseQuantity $unit ${ingredient.name}';

  /// Get quantity as double (if possible)
  double? get quantityAsDouble => double.tryParse(baseQuantity);
}
