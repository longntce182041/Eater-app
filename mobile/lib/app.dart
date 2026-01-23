import 'package:flutter/material.dart';

import 'src/config/router/app_router.dart';
import 'src/config/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // NOTE: No UI layout here, only structure.
    return MaterialApp.router(
      title: 'AI Healthy Meal Planner',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: appRouter,
    );
  }
}