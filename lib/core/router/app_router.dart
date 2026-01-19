import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/meal_plans/presentation/pages/meal_plans_page.dart';
import '../../features/recipes/presentation/pages/recipes_page.dart';
import '../../features/recipes/presentation/pages/recipe_detail_page.dart';
import '../../features/user_profile/presentation/pages/user_profile_page.dart';
import '../../features/dietary_preferences/presentation/pages/dietary_preferences_page.dart';
import '../../features/meal_logging/presentation/pages/meal_logging_page.dart';
import '../../features/shopping_list/presentation/pages/shopping_list_page.dart';

/// Provider for the application router.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      // Authentication routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/reset-password',
        name: 'reset-password',
        builder: (context, state) => const ResetPasswordPage(),
      ),

      // Main app routes
      GoRoute(
        path: '/meal-plans',
        name: 'meal-plans',
        builder: (context, state) => const MealPlansPage(),
      ),
      GoRoute(
        path: '/recipes',
        name: 'recipes',
        builder: (context, state) => const RecipesPage(),
      ),
      GoRoute(
        path: '/recipes/:id',
        name: 'recipe-detail',
        builder: (context, state) {
          final recipeId = state.pathParameters['id']!;
          return RecipeDetailPage(recipeId: recipeId);
        },
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const UserProfilePage(),
      ),
      GoRoute(
        path: '/dietary-preferences',
        name: 'dietary-preferences',
        builder: (context, state) => const DietaryPreferencesPage(),
      ),
      GoRoute(
        path: '/meal-logging',
        name: 'meal-logging',
        builder: (context, state) => const MealLoggingPage(),
      ),
      GoRoute(
        path: '/shopping-list',
        name: 'shopping-list',
        builder: (context, state) => const ShoppingListPage(),
      ),
    ],
  );
});
