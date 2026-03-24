import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;

    // Listen to targetTabIndexProvider for auto-navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.listen(targetTabIndexProvider, (previous, next) {
        if (!mounted) return;
        if (next != null) {
          setState(() {
            _currentIndex = next;
          });
          print('[main_navigation_page] Auto-navigated to tab: $next');
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
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
          BottomNavigationBarItem(
              icon: Icon(Icons.medical_services_outlined),
              activeIcon: Icon(Icons.medical_services),
              label: 'Nutritionist'),
        ],
      ),
    );
  }
}
