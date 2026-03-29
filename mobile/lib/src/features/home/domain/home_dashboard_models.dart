/// 📊 HOME DASHBOARD DATA MODELS
///
/// This file contains all data models for the home dashboard feature:
/// - HomeOverviewData: Main dashboard data container
/// - HomeD ashboardData: Extended dashboard with today's meals
/// - UpcomingMealsData: Upcoming meals for next N days
/// - Supporting models: CalorieData, MealData, MacroData, TodayMeal, etc.
///
/// All models implement:
/// - fromJson() → Parse API JSON to Dart object
/// - toJson() → Serialize Dart object to JSON
/// - Null-safety with default values

/// 🏠 Home Overview Data
///
/// Contains the main dashboard statistics visible on home page:
/// - calories: Today's calorie progress (consumed vs target)
/// - meals: Today's meal count progress
/// - macros: Macro nutrients breakdown (protein, carbs, fats)
///
/// Usage in UI:
/// ```dart
/// Text('${overview.calories.consumed}/${overview.calories.target} kcal')
/// ```
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

/// 🔥 Calorie Data
///
/// Tracks daily calorie consumption:
/// - consumed: Total calories eaten today (integer)
/// - target: User's daily calorie goal (default: 2000)
/// - percentage: Consumed as % of target (0-100+)
///
/// Example:
/// ```
/// consumed: 1500
/// target: 2000
/// percentage: 75
/// ```
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

/// 🍽️ Meal Data
///
/// Tracks meal consumption progress:
/// - consumed: Number of meals logged today
/// - target: Daily meal goal (default: 3)
///
/// Example:
/// ```
/// consumed: 2 (breakfast + lunch)
/// target: 3
/// ```
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

/// 🥗 Macro Data
///
/// Macro nutrients breakdown (in grams):
/// - protein: Total protein today
/// - carbohydrates: Total carbs today
/// - fat: Total fat today
///
/// Used in:
/// - Macro pie chart / bar chart
/// - Nutrition progress display
///
/// Example:
/// ```
/// protein: 120g
/// carbohydrates: 150g
/// fat: 50g
/// ```
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

/// 🍴 Today's Meal
///
/// Represents a single meal logged today with:
/// - id: Unique meal ID
/// - mealType: "breakfast", "lunch", "dinner", or "snack"
/// - recipeName: Name of the recipe
/// - recipeImageUrl: Image of the dish (optional)
/// - servings: Number of servings
/// - calories, protein, carbohydrates, fat: Nutrition values
/// - userRating: User's rating for this meal (1-5, optional)
///
/// Used in: Today's meals list on home page
///
/// Example:
/// ```
/// id: "meal_123"
/// mealType: "breakfast"
/// recipeName: "Scrambled Eggs with Toast"
/// calories: 350
/// protein: 15
/// ```
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
