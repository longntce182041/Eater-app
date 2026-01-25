import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/routes/auth_routes.dart';
import '../../features/home/presentation/pages/main_navigation_page.dart';
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

      final isAuthRoute =
          state.matchedLocation.startsWith('/sign-in') ||
          state.matchedLocation.startsWith('/sign-up') ||
          state.matchedLocation.startsWith('/forgot-password') ||
          state.matchedLocation.startsWith('/reset-password') ||
          state.matchedLocation.startsWith('/verify-email');

      // If not authenticated and trying to access protected route, redirect to sign in
      if (!isAuthenticated && !isAuthRoute) {
        return '/sign-in';
      }

      // If authenticated and on auth route, redirect to home
      if (isAuthenticated && isAuthRoute) {
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
      ...authRoutes,
    ],
  );
});
