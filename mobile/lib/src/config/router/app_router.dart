import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/routes/auth_routes.dart';
import '../../features/meal_plans/presentation/routes/meal_plan_routes.dart';

final GoRouter appRouter = appRouter (
  routes: [
    ...authRoutes,
    ...mealPlanRoutes,
    // Add more feature routes here.
  ],
);