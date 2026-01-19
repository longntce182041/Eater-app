// API Constants
class ApiConstants {
  static const String baseUrl = 'https://api.example.com';
  static const String apiVersion = '/api/v1';
  
  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  
  // Profile endpoints
  static const String profile = '/profile';
  static const String healthInfo = '/profile/health';
  
  // Dietary preferences endpoints
  static const String dietaryPreferences = '/preferences/dietary';
  
  // Meal plan endpoints
  static const String mealPlan = '/meal-plans';
  static const String dailyMealPlan = '/meal-plans/daily';
  static const String weeklyMealPlan = '/meal-plans/weekly';
  static const String generateMealPlan = '/meal-plans/generate';
  
  // Recipe endpoints
  static const String recipes = '/recipes';
  static const String recipeDetails = '/recipes/{id}';
  static const String searchRecipes = '/recipes/search';
  
  // Meal logging endpoints
  static const String mealLogs = '/meals/logs';
  
  // Nutrition tracking endpoints
  static const String nutritionTracking = '/nutrition/tracking';
  static const String nutritionHistory = '/nutrition/history';
  
  // Shopping list endpoints
  static const String shoppingList = '/shopping-list';
}

// App Constants
class AppConstants {
  static const String appName = 'AI Healthy Meal Planner';
  static const int requestTimeout = 30000; // 30 seconds
  static const int maxRetryAttempts = 3;
}

// Storage Keys
class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String isLoggedIn = 'is_logged_in';
  static const String userProfile = 'user_profile';
  static const String dietaryPreferences = 'dietary_preferences';
}
