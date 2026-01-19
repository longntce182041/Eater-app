// App Routes
class AppRoutes {
  // Auth routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  
  // Main routes
  static const String home = '/home';
  
  // Profile routes
  static const String profile = '/profile';
  static const String healthInfo = '/profile/health';
  static const String editProfile = '/profile/edit';
  
  // Dietary preferences routes
  static const String dietaryPreferences = '/dietary-preferences';
  
  // Meal plan routes
  static const String mealPlan = '/meal-plan';
  static const String dailyMealPlan = '/meal-plan/daily';
  static const String weeklyMealPlan = '/meal-plan/weekly';
  static const String generateMealPlan = '/meal-plan/generate';
  
  // Recipe routes
  static const String recipes = '/recipes';
  static const String recipeDetails = '/recipes/:id';
  static const String searchRecipes = '/recipes/search';
  
  // Meal logging routes
  static const String mealLogging = '/meal-logging';
  static const String logMeal = '/meal-logging/log';
  
  // Nutrition tracking routes
  static const String nutritionTracking = '/nutrition';
  static const String nutritionHistory = '/nutrition/history';
  
  // Shopping list routes
  static const String shoppingList = '/shopping-list';
}
