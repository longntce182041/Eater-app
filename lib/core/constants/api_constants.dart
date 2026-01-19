/// API endpoints and base URL configuration.
class ApiConstants {
  ApiConstants._();

  /// Base URL for the API
  static const String baseUrl = 'https://api.aihealthymealplanner.com/v1';

  /// Authentication endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String resetPassword = '/auth/reset-password';
  static const String forgotPassword = '/auth/forgot-password';

  /// User profile endpoints
  static const String userProfile = '/users/profile';
  static const String updateProfile = '/users/profile';
  static const String healthInfo = '/users/health-info';

  /// Dietary preferences endpoints
  static const String dietaryPreferences = '/users/dietary-preferences';
  static const String healthGoals = '/users/health-goals';
  static const String allergies = '/users/allergies';

  /// Meal plans endpoints
  static const String mealPlans = '/meal-plans';
  static const String dailyMealPlan = '/meal-plans/daily';
  static const String weeklyMealPlan = '/meal-plans/weekly';
  static const String generateMealPlan = '/meal-plans/generate';

  /// Recipes endpoints
  static const String recipes = '/recipes';
  static const String recipeDetail = '/recipes/{id}';
  static const String searchRecipes = '/recipes/search';
  static const String favoriteRecipes = '/recipes/favorites';

  /// Meal logging endpoints
  static const String mealLogs = '/meal-logs';
  static const String nutritionSummary = '/meal-logs/nutrition-summary';

  /// Shopping list endpoints
  static const String shoppingList = '/shopping-list';
  static const String shoppingListItems = '/shopping-list/items';
}
