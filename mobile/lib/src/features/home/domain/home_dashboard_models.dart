class HomeOverviewData {
  final CalorieData calories;
  final MealData meals;
  final MacroData macros;

  HomeOverviewData({
    required this.calories,
    required this.meals,
    required this.macros,
  });

  factory HomeOverviewData.fromJson(Map<String, dynamic> json) {
    return HomeOverviewData(
      calories: CalorieData.fromJson(json['calories'] as Map<String, dynamic>),
      meals: MealData.fromJson(json['meals'] as Map<String, dynamic>),
      macros: MacroData.fromJson(json['macros'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories.toJson(),
      'meals': meals.toJson(),
      'macros': macros.toJson(),
    };
  }
}

class CalorieData {
  final int consumed;
  final int target;
  final int percentage;

  CalorieData({
    required this.consumed,
    required this.target,
    required this.percentage,
  });

  factory CalorieData.fromJson(Map<String, dynamic> json) {
    return CalorieData(
      consumed: (json['consumed'] as num?)?.toInt() ?? 0,
      target: (json['target'] as num?)?.toInt() ?? 2000,
      percentage: (json['percentage'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'consumed': consumed,
      'target': target,
      'percentage': percentage,
    };
  }
}

class MealData {
  final int consumed;
  final int target;

  MealData({
    required this.consumed,
    required this.target,
  });

  factory MealData.fromJson(Map<String, dynamic> json) {
    return MealData(
      consumed: (json['consumed'] as num?)?.toInt() ?? 0,
      target: (json['target'] as num?)?.toInt() ?? 3,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'consumed': consumed,
      'target': target,
    };
  }
}

class MacroData {
  final int protein;
  final int carbohydrates;
  final int fat;

  MacroData({
    required this.protein,
    required this.carbohydrates,
    required this.fat,
  });

  factory MacroData.fromJson(Map<String, dynamic> json) {
    return MacroData(
      protein: (json['protein'] as num?)?.toInt() ?? 0,
      carbohydrates: (json['carbohydrates'] as num?)?.toInt() ?? 0,
      fat: (json['fat'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'protein': protein,
      'carbohydrates': carbohydrates,
      'fat': fat,
    };
  }
}

class TodayMeal {
  final String id;
  final String mealType;
  final String recipeName;
  final String? recipeImageUrl;
  final int servings;
  final int calories;
  final int protein;
  final int carbohydrates;
  final int fat;
  final int? userRating;

  TodayMeal({
    required this.id,
    required this.mealType,
    required this.recipeName,
    this.recipeImageUrl,
    required this.servings,
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    this.userRating,
  });

  factory TodayMeal.fromJson(Map<String, dynamic> json) {
    return TodayMeal(
      id: json['id'] as String? ?? '',
      mealType: json['mealType'] as String? ?? '',
      recipeName: json['recipeName'] as String? ?? '',
      recipeImageUrl: json['recipeImageUrl'] as String?,
      servings: (json['servings'] as num?)?.toInt() ?? 1,
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      protein: (json['protein'] as num?)?.toInt() ?? 0,
      carbohydrates: (json['carbohydrates'] as num?)?.toInt() ?? 0,
      fat: (json['fat'] as num?)?.toInt() ?? 0,
      userRating: json['userRating'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mealType': mealType,
      'recipeName': recipeName,
      'recipeImageUrl': recipeImageUrl,
      'servings': servings,
      'calories': calories,
      'protein': protein,
      'carbohydrates': carbohydrates,
      'fat': fat,
      'userRating': userRating,
    };
  }
}

class HomeDashboardData {
  final HomeOverviewData todayOverview;
  final List<TodayMeal> todaysMeals;
  final Map<String, dynamic>? userProfile;
  final Map<String, dynamic>? healthMetrics;
  final Map<String, dynamic>? latestMealPlan;

  HomeDashboardData({
    required this.todayOverview,
    required this.todaysMeals,
    this.userProfile,
    this.healthMetrics,
    this.latestMealPlan,
  });

  factory HomeDashboardData.fromJson(Map<String, dynamic> json) {
    final mealsJson = json['todaysMeals'] as List<dynamic>? ?? [];
    final meals = mealsJson
        .map((e) => TodayMeal.fromJson(e as Map<String, dynamic>))
        .toList();

    return HomeDashboardData(
      todayOverview: HomeOverviewData.fromJson(
        json['todayOverview'] as Map<String, dynamic>? ?? {},
      ),
      todaysMeals: meals,
      userProfile: json['userProfile'] as Map<String, dynamic>?,
      healthMetrics: json['healthMetrics'] as Map<String, dynamic>?,
      latestMealPlan: json['latestMealPlan'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'todayOverview': todayOverview.toJson(),
      'todaysMeals': todaysMeals.map((m) => m.toJson()).toList(),
      'userProfile': userProfile,
      'healthMetrics': healthMetrics,
      'latestMealPlan': latestMealPlan,
    };
  }
}

class UpcomingMealsData {
  final Map<String, dynamic>? mealPlan;
  final Map<int, List<TodayMeal>> upcomingMeals;

  UpcomingMealsData({
    this.mealPlan,
    required this.upcomingMeals,
  });

  factory UpcomingMealsData.fromJson(Map<String, dynamic> json) {
    final upcomingJson = json['upcomingMeals'] as Map<String, dynamic>? ?? {};
    final upcomingMeals = <int, List<TodayMeal>>{};

    upcomingJson.forEach((dayKey, meals) {
      final dayIndex = int.tryParse(dayKey) ?? 0;
      final mealsList = (meals as List<dynamic>)
          .map((e) => TodayMeal.fromJson(e as Map<String, dynamic>))
          .toList();
      upcomingMeals[dayIndex] = mealsList;
    });

    return UpcomingMealsData(
      mealPlan: json['mealPlan'] as Map<String, dynamic>?,
      upcomingMeals: upcomingMeals,
    );
  }

  Map<String, dynamic> toJson() {
    final upcomingJson = <String, dynamic>{};
    upcomingMeals.forEach((dayIndex, meals) {
      upcomingJson[dayIndex.toString()] = meals.map((m) => m.toJson()).toList();
    });

    return {
      'mealPlan': mealPlan,
      'upcomingMeals': upcomingJson,
    };
  }

  /// Get meals for a specific day
  List<TodayMeal> getMealsForDay(int dayIndex) {
    return upcomingMeals[dayIndex] ?? [];
  }

  /// Get all distinct day indices with meals
  List<int> getDaysWithMeals() {
    return upcomingMeals.keys.toList()..sort();
  }
}
