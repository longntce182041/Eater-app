import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/routes/auth_routes.dart';
import '../../features/home/presentation/pages/main_navigation_page.dart';
import '../../features/reminders/presentation/pages/reminders_page.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/userHeath/presentation/pages/set_age.dart';
import '../../features/userHeath/presentation/pages/set_height.dart';
import '../../features/userHeath/presentation/pages/set_weight.dart';
import '../../features/userHeath/presentation/pages/set_gender_activity.dart';
import '../../features/userHeath/presentation/pages/profile_summary.dart';
import '../../features/userHeath/presentation/pages/dietary_references_screen.dart';
import '../../features/userHeath/presentation/pages/user_info_screen.dart';
import '../../features/userHeath/presentation/screens/select_diet_type_page.dart';
import '../../features/userHeath/presentation/screens/select_allergies_page.dart';
import '../../features/userHeath/presentation/screens/select_dislikes_page.dart';
import '../../features/userHeath/presentation/screens/select_activity_level_page.dart';
import '../../features/userHeath/presentation/screens/select_cooking_page.dart';
import '../../features/userHeath/presentation/screens/select_cooking_time_page.dart';
import '../../features/userHeath/presentation/screens/select_calories_page.dart';
import 'auth_notifier.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/sign-in',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      // Wait for initialization
      if (!authNotifier.isInitialized) {
        return null;
      }

      final isAuthenticated = authNotifier.isAuthenticated;

      final isAuthRoute = state.matchedLocation.startsWith('/sign-in') ||
          state.matchedLocation.startsWith('/sign-up') ||
          state.matchedLocation.startsWith('/forgot-password') ||
          state.matchedLocation.startsWith('/reset-password') ||
          state.matchedLocation.startsWith('/verify-email') ||
          state.matchedLocation.startsWith('/user-info') ||
          state.matchedLocation.startsWith('/set-age') ||
          state.matchedLocation.startsWith('/set-height') ||
          state.matchedLocation.startsWith('/set-weight') ||
          state.matchedLocation.startsWith('/set-gender') ||
          state.matchedLocation.startsWith('/select-diet-type') ||
          state.matchedLocation.startsWith('/select-allergies') ||
          state.matchedLocation.startsWith('/select-dislikes') ||
          state.matchedLocation.startsWith('/select-activity-level') ||
          state.matchedLocation.startsWith('/select-cooking') ||
          state.matchedLocation.startsWith('/select-cooking-time') ||
          state.matchedLocation.startsWith('/select-calories') ||
          state.matchedLocation.startsWith('/profile-summary');

      // If not authenticated and trying to access protected route, redirect to sign in
      if (!isAuthenticated && !isAuthRoute) {
        return '/sign-in';
      }

      // If authenticated and on auth route, redirect to home
      if (isAuthenticated &&
          isAuthRoute &&
          !state.matchedLocation.startsWith('/user-info') &&
          !state.matchedLocation.startsWith('/set-age') &&
          !state.matchedLocation.startsWith('/set-height') &&
          !state.matchedLocation.startsWith('/set-weight') &&
          !state.matchedLocation.startsWith('/set-gender') &&
          !state.matchedLocation.startsWith('/select-diet-type') &&
          !state.matchedLocation.startsWith('/select-allergies') &&
          !state.matchedLocation.startsWith('/select-dislikes') &&
          !state.matchedLocation.startsWith('/select-activity-level') &&
          !state.matchedLocation.startsWith('/select-cooking') &&
          !state.matchedLocation.startsWith('/select-cooking-time') &&
          !state.matchedLocation.startsWith('/select-calories') &&
          !state.matchedLocation.startsWith('/profile-summary')) {
        return '/home';
      }

      // No redirect needed
      return null;
    },
    routes: [
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainNavigationPage(),
      ),
      GoRoute(
        path: '/user-info',
        builder: (context, state) => const UserInfoScreen(),
      ),
      GoRoute(path: '/set-age', builder: (context, state) => const AgeScreen()),
      GoRoute(
        path: '/set-height',
        builder: (context, state) => const SetHeightPage(),
      ),
      GoRoute(
        path: '/set-weight',
        builder: (context, state) => const SetWeightPage(),
      ),
      GoRoute(
        path: '/set-gender',
        builder: (context, state) => const SetGenderActivityPage(),
      ),
      GoRoute(
        path: '/profile-summary',
        builder: (context, state) => const ProfileSummaryPage(),
      ),
      GoRoute(
        path: '/dietary-references',
        builder: (context, state) => const DietaryReferencesScreen(),
      ),
      GoRoute(
        path: '/select-diet-type',
        builder: (context, state) => const SelectDietTypePage(),
      ),
      GoRoute(
        path: '/select-allergies',
        builder: (context, state) => const SelectAllergiesPage(),
      ),
      GoRoute(
        path: '/select-dislikes',
        builder: (context, state) => const SelectDislikesPage(),
      ),
      GoRoute(
        path: '/select-activity-level',
        builder: (context, state) => const SelectActivityLevelPage(),
      ),
      GoRoute(
        path: '/select-cooking',
        builder: (context, state) => const SelectCookingPage(),
      ),
      GoRoute(
        path: '/select-cooking-time',
        builder: (context, state) => const SelectCookingTimePage(),
      ),
      GoRoute(
        path: '/select-calories',
        builder: (context, state) => const SelectCaloriesPage(),
      ),
      GoRoute(
        path: '/reminders',
        builder: (context, state) => const RemindersPage(),
      ),
      GoRoute(
        path: '/chat/:nutritionistId',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return ChatPage(
            nutritionistId: state.pathParameters['nutritionistId']!,
            nutritionistName: extra['nutritionistName'] as String? ?? 'Nutritionist',
          );
        },
      ),
      ...authRoutes,
    ],
  );
});
