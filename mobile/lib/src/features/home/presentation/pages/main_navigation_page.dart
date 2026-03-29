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

/// 🗺️ MAIN NAVIGATION PAGE
///
/// Central navigation hub for the entire app.
/// Manages bottom navigation bar and page switching.
///
/// Tabs (6 main + 1 hidden):
/// 0. Home - Dashboard overview
/// 1. Meals - Log daily meals
/// 2. Plans - Meal plans
/// 3. Recipes - Browse recipes
/// 4. Groceries - Shopping list
/// 5. Profile - User profile settings
/// 6. Chat - Nutritionist chat (hidden from bottom bar)
///
/// Architecture:
/// - Uses Riverpod for navigation state (mainNavigationIndexProvider)
/// - Listens to targetTabIndexProvider for external navigation requests
/// - Manages bottom navigation bar visibility (hidden on chat page)
class MainNavigationPage extends ConsumerStatefulWidget {
  const MainNavigationPage({super.key});

  @override
  ConsumerState<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends ConsumerState<MainNavigationPage> {
  /// 🎯 Initialize Navigation Listeners
  ///
  /// Setup:
  /// 1. Wait for first frame (ensures widget is mounted)
  /// 2. Listen to targetTabIndexProvider
  /// 3. When target set, navigate to that tab
  /// 4. Clear target after navigation
  ///
  /// Why this pattern?
  /// - Allows other screens to request navigation via Riverpod
  /// - Example: MealPlan screen can say "navigate to Recipes tab"
  /// - Prevents direct coupling between screens
  @override
  void initState() {
    super.initState();

    // Listen to targetTabIndexProvider for auto-navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.listen(targetTabIndexProvider, (previous, next) {
        if (!mounted) return;
        if (next != null) {
          // Clamp index to valid range (0 to _pages.length - 1)
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

  /// 📄 List of Pages for Each Tab
  ///
  /// Order matches bottom navigation indices:
  /// 0 → HomePage
  /// 1 → MealLoggingPage
  /// 2 → MealPlanPage
  /// 3 → RecipesPage
  /// 4 → GroceriesPage
  /// 5 → ProfilePage
  /// 6 → NutritionistListPage (hidden from bottom bar)
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
    /// 🏗️ Build Main Navigation UI
    ///
    /// Structure:
    /// - Scaffold with body (current page) + bottom nav bar
    /// - Body: Display current page from _pages list
    /// - BottomNavigationBar: 6 items (hide on chat page)
    ///
    /// Logic:
    /// 1. Watch mainNavigationIndexProvider for current tab
    /// 2. Clamp index to valid range
    /// 3. Check if we should show bottom bar (index < 6)
    /// 4. Build page list with conditional bottom bar
    final currentIndex = ref.watch(mainNavigationIndexProvider);
    final safeIndex = currentIndex.clamp(0, _pages.length - 1);
    const tabCount = 6;
    final showBottomBar = safeIndex < tabCount;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),

      /// Display current page based on selected tab
      body: _pages[safeIndex],

      /// Bottom navigation bar (hidden on chat page)
      ///
      /// Tabs:
      /// - Home: Dashboard overview
      /// - Meals: Daily meal logging
      /// - Plans: Manage meal plans
      /// - Recipes: Browse & search recipes
      /// - Groceries: Shopping list
      /// - Profile: User preferences & profile
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
