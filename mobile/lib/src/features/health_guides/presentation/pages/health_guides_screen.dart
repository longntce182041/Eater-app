import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/health_guide_models.dart';
import '../providers/health_guides_provider.dart';
import '../widgets/category_tab_bar.dart';
import '../widgets/guide_card.dart';
import '../widgets/guide_detail_sheet.dart';

/// 📚 HEALTH & LIFESTYLE GUIDES SCREEN
///
/// Full-screen modal for browsing educational health guides
///
/// Features:
/// - Browse guides by category (fasting, nutrition, workouts, etc.)
/// - Category tabs for easy switching
/// - Guide cards with preview information
/// - Bottom sheet detail view for full content
/// - Loading and error states
///
/// User Flow:
/// 1. User taps "Health & Lifestyle Guides" button on profile
/// 2. Modal opens showing all categories
/// 3. First category selected by default
/// 4. User sees list of guides in that category
/// 5. User taps guide card
/// 6. Bottom sheet opens with full content
/// 7. User can read, scroll, close
/// 8. Return to guide list to browse others
///
/// Architecture:
/// - ConsumerStatefulWidget: Tracks selected category
/// - AsyncValue.when() for loading/error/data states
/// - Galaxy TabBar: Horizontal scrolling tabs
/// - GuideCard: Preview each guide
/// - GuideDetailSheet: Full content modal
///
/// State:
/// - _selectedCategory: Currently selected category (local state)
/// - allHealthGuidesProvider: Categories with guides (Riverpod)
/// - guideDetailProvider: Full guide content (Riverpod, lazy-loaded)
class HealthGuidesScreen extends ConsumerStatefulWidget {
  const HealthGuidesScreen({super.key});

  @override
  ConsumerState<HealthGuidesScreen> createState() => _HealthGuidesScreenState();
}

class _HealthGuidesScreenState extends ConsumerState<HealthGuidesScreen> {
  late String? _selectedCategory;

  /// 🎯 Initialize State
  ///
  /// Set selected category to null initially
  /// Will be set to first category once data loads
  @override
  void initState() {
    super.initState();
    _selectedCategory = null;
  }

  @override
  Widget build(BuildContext context) {
    /// 🏗️ Build Main UI with Async Data Handling
    ///
    /// Watch allHealthGuidesProvider to trigger API request
    /// Use AsyncValue.when() to handle three states:
    /// 1. loading: Show spinner
    /// 2. error: Show error message + retry button
    /// 3. data: Show category tabs + guide list
    final allGuidesAsync = ref.watch(allHealthGuidesProvider);

    return Scaffold(
      /// AppBar: Header with title and close button
      ///
      /// Allows user to exit guides modal
      /// Shows: "Health & Lifestyle Guides" title, close icon
      appBar: AppBar(
        title: const Text('Health & Lifestyle Guides'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),

      /// Body: Async data handling with three states
      ///
      /// loading: Spinner while fetching guides
      /// error: Error message with retry button
      /// data: Full UI with tabs and guide list
      body: allGuidesAsync.when(
        /// ⏳ Loading State: Show spinner
        ///
        /// Displayed while fetching categories from backend
        /// Use orange color (#FF9800) to match app theme
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF9800)),
        ),

        /// ❌ Error State: Show error + retry
        ///
        /// Displayed if API request failed
        /// Shows: error icon, error message, retry button
        /// Retry button: calls ref.refresh(allHealthGuidesProvider)
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => ref.refresh(allHealthGuidesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),

        /// ✅ Success State: Show content
        ///
        /// Displayed after successfully fetching guides
        /// Delegate to _buildContent() for layout
        data: (categories) => _buildContent(context, categories),
      ),
    );
  }

  /// 📱 Build Main Content (Categories + Guides)
  ///
  /// Layout:
  /// ```
  /// ┌──────────────────────────────┐
  /// │ [Fasting] [Workouts] [Nutrition] │  ← Category tabs
  /// ├──────────────────────────────┤
  /// │ Guide Card 1                 │
  /// │ Guide Card 2                 │
  /// │ Guide Card 3                 │
  /// │ ...                          │
  /// └──────────────────────────────┘
  /// ```
  ///
  /// Inputs:
  /// - categories: `List<HealthGuideCategory>` from API
  ///
  /// Logic:
  /// 1. Check if empty → show "no guides" message
  /// 2. Extract category names for tabs
  /// 3. Set _selectedCategory to first if null
  /// 4. Find selected category from list
  /// 5. Build tabs + guide list
  Widget _buildContent(
    BuildContext context,
    List<HealthGuideCategory> categories,
  ) {
    /// Handle empty list
    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No guides available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    /// 📌 Extract category names for tabs
    /// Example: ["fasting", "nutrition", "workouts"]
    final categoryNames =
        categories.map((c) => c.category).toList();

    /// 🎯 Set default category
    /// On first load, select first category
    /// Prevents _selectedCategory from being null
    if (_selectedCategory == null && categoryNames.isNotEmpty) {
      _selectedCategory = categoryNames.first;
    }

    /// 🔍 Find the selected category object
    /// Get guides for the currently selected category
    /// If category not found (shouldn't happen), create empty category
    final selectedCategory = _selectedCategory != null
        ? categories.firstWhere(
            (c) => c.category == _selectedCategory,
            orElse: () => HealthGuideCategory(category: '', guides: []),
          )
        : null;

    /// 📚 Extract list of guides for selected category
    final selectedGuides = selectedCategory?.guides ?? [];

    /// 🏗️ Build Two-Part Layout: Tabs + Guide List
    ///
    /// Part 1: Category tabs (CategoryTabBar)
    /// - Horizontal scrolling tabs
    /// - Shows all categories user can select
    /// - Currently selected shown in orange
    ///
    /// Part 2: Guide list (ListView.builder)
    /// - Scrollable list of guides in selected category
    /// - Each item is GuideCard (preview)
    /// - Tap to open detail sheet
    return Column(
      children: [
        /// 🏷️ Category Tabs
        ///
        /// Horizontal scrolling tabs showing all categories
        /// Selected tab: orange background
        /// Unselected tab: white background, gray border
        ///
        /// Props:
        /// - categories: Category names (fasting, nutrition, etc.)
        /// - selectedCategory: Currently selected (e.g., 'fasting')
        /// - onCategorySelect: Callback when user taps category
        ///
        /// Action: setState() to update _selectedCategory
        /// UI automatically rebuilds to show guides for new category
        CategoryTabBar(
          categories: categoryNames,
          selectedCategory: _selectedCategory,
          onCategorySelect: (category) {
            setState(() {
              _selectedCategory = category;
            });
          },
        ),

        /// 📋 Guide List
        ///
        /// Expanded: Takes remaining vertical space
        /// Empty state: Shows "No guides in this category" if list empty
        /// Full state: ListView.builder with guide cards
        Expanded(
          child: selectedGuides.isEmpty
              /// 📭 Empty State: No guides in selected category
              ?
              Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lightbulb, size: 48, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No guides in this category',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              /// ✅ Full State: Display guides as list
              :
              ListView.builder(
                /// Padding: 16px horizontal, 8px vertical
                /// Adds spacing from edges
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

                /// Build list items
                itemCount: selectedGuides.length,
                itemBuilder: (context, index) {
                  final guide = selectedGuides[index];

                  /// 🎴 Guide Card Wrapper
                  ///
                  /// Each guide shown as GuideCard
                  /// Card displays: title, description, difficulty, read time, tags
                  ///
                  /// Tap action: Show detail sheet
                  /// showModalBottomSheet opens GuideDetailSheet
                  /// Passes guideId to fetch full content
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GuideCard(
                      guide: guide,
                      onTap: () {
                        /// Open detail sheet with guide content
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) =>
                              GuideDetailSheet(guideId: guide.id),
                        );
                      },
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }
}
