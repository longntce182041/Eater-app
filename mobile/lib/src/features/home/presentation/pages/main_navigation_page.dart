import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/navigation_provider.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'recipes_page.dart';
import '../../../meal_plan/presentation/pages/meal_plan_page.dart';
import '../../../grocery/presentation/pages/groceries_page.dart';
import '../../../chat/presentation/pages/nutritionist_list_page.dart';
import '../../../nutrition/presentation/pages/meal_logging_page.dart';
import '../../../nutrition/presentation/providers/navigation_provider.dart';

class MainNavigationPage extends ConsumerStatefulWidget {
  const MainNavigationPage({super.key});

  @override
  ConsumerState<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends ConsumerState<MainNavigationPage> {
  @override
  void initState() {
    super.initState();

    // Listen to targetTabIndexProvider for auto-navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.listen(targetTabIndexProvider, (previous, next) {
        if (!mounted) return;
        if (next != null) {
          final safeIndex = next.clamp(0, _pages.length - 1);
          ref.read(mainNavigationIndexProvider.notifier).state = safeIndex;
          debugPrint('[main_navigation_page] Auto-navigated to tab: $next');
          // Clear the target tab after using it (delayed to avoid provider modification during build)
          Future.microtask(() {
            ref.read(targetTabIndexProvider.notifier).clearTargetTab();
          });
        }
      });
    });
  }

  final List<Widget> _pages = [
    const HomePage(),
    const MealLoggingPage(),
    const MealPlanPage(),
    const RecipesPage(),
    const GroceriesPage(),
    const ProfilePage(),
    const NutritionistListPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(mainNavigationIndexProvider);
    final safeIndex = currentIndex.clamp(0, _pages.length - 1);
    const tabCount = 6;
    final showBottomBar = safeIndex < tabCount;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: _pages[safeIndex],
      bottomNavigationBar: showBottomBar
          ? BottomNavigationBar(
              currentIndex: safeIndex,
              onTap: (index) =>
                  ref.read(mainNavigationIndexProvider.notifier).state = index,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: const Color(0xFFFF9800),
              unselectedItemColor: Colors.grey[400],
              elevation: 8,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.restaurant_outlined),
                  activeIcon: Icon(Icons.restaurant),
                  label: 'Meals',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today_outlined),
                  activeIcon: Icon(Icons.calendar_today),
                  label: 'Plans',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.restaurant_menu_outlined),
                  activeIcon: Icon(Icons.restaurant_menu),
                  label: 'Recipes',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_bag_outlined),
                  activeIcon: Icon(Icons.shopping_bag),
                  label: 'Groceries',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outlined),
                  activeIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            )
          : null,
    );
  }
}
