import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/health_guide_models.dart';
import '../providers/health_guides_provider.dart';
import '../widgets/category_tab_bar.dart';
import '../widgets/guide_card.dart';
import '../widgets/guide_detail_sheet.dart';

/// Full-screen modal for browsing health guides
class HealthGuidesScreen extends ConsumerStatefulWidget {
  const HealthGuidesScreen({super.key});

  @override
  ConsumerState<HealthGuidesScreen> createState() => _HealthGuidesScreenState();
}

class _HealthGuidesScreenState extends ConsumerState<HealthGuidesScreen> {
  late String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = null;
  }

  @override
  Widget build(BuildContext context) {
    final allGuidesAsync = ref.watch(allHealthGuidesProvider);

    return Scaffold(
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
      body: allGuidesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF9800)),
        ),
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
        data: (categories) => _buildContent(context, categories),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<HealthGuideCategory> categories,
  ) {
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

    // Extract category names
    final categoryNames =
        categories.map((c) => c.category).toList();

    // Set default category if not set
    if (_selectedCategory == null && categoryNames.isNotEmpty) {
      _selectedCategory = categoryNames.first;
    }

    // Get guides for selected category
    final selectedCategory = _selectedCategory != null
        ? categories.firstWhere(
            (c) => c.category == _selectedCategory,
            orElse: () => HealthGuideCategory(category: '', guides: []),
          )
        : null;

    final selectedGuides = selectedCategory?.guides ?? [];

    return Column(
      children: [
        // Category tabs
        CategoryTabBar(
          categories: categoryNames,
          selectedCategory: _selectedCategory,
          onCategorySelect: (category) {
            setState(() {
              _selectedCategory = category;
            });
          },
        ),
        // Guides list
        Expanded(
          child: selectedGuides.isEmpty
              ? Center(
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
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: selectedGuides.length,
                  itemBuilder: (context, index) {
                    final guide = selectedGuides[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GuideCard(
                        guide: guide,
                        onTap: () {
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
