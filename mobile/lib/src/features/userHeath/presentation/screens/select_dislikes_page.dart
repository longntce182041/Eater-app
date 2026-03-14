import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/dietary_ref_provider.dart';

// Food item model
class FoodItem {
  final String id;
  final String name;
  final String emoji;

  const FoodItem({required this.id, required this.name, required this.emoji});
}

class SelectDislikesPage extends ConsumerStatefulWidget {
  const SelectDislikesPage({super.key});

  @override
  ConsumerState<SelectDislikesPage> createState() => _SelectDislikesPageState();
}

class _SelectDislikesPageState extends ConsumerState<SelectDislikesPage> {
  // Common products with emojis
  final List<FoodItem> _allProducts = const [
    FoodItem(id: 'shrimp', name: 'Shrimp', emoji: '🦐'),
    FoodItem(id: 'eggs', name: 'Eggs', emoji: '🥚'),
    FoodItem(id: 'brussel_sprout', name: 'Brussel sprout', emoji: '🥬'),
    FoodItem(id: 'mushrooms', name: 'Mushrooms', emoji: '🍄'),
    FoodItem(id: 'onions', name: 'Onions', emoji: '🧅'),
    FoodItem(id: 'garlic', name: 'Garlic', emoji: '🧄'),
    FoodItem(id: 'tomatoes', name: 'Tomatoes', emoji: '🍅'),
    FoodItem(id: 'peppers', name: 'Peppers', emoji: '🌶️'),
    FoodItem(id: 'broccoli', name: 'Broccoli', emoji: '🥦'),
    FoodItem(id: 'spinach', name: 'Spinach', emoji: '🥬'),
    FoodItem(id: 'carrots', name: 'Carrots', emoji: '🥕'),
    FoodItem(id: 'cilantro', name: 'Cilantro', emoji: '🌿'),
    FoodItem(id: 'olives', name: 'Olives', emoji: '🫒'),
    FoodItem(id: 'eggplant', name: 'Eggplant', emoji: '🍆'),
    FoodItem(id: 'cauliflower', name: 'Cauliflower', emoji: '🥦'),
    FoodItem(id: 'fish', name: 'Fish', emoji: '🐟'),
    FoodItem(id: 'cheese', name: 'Cheese', emoji: '🧀'),
    FoodItem(id: 'nuts', name: 'Nuts', emoji: '🥜'),
  ];

  final Set<String> _dislikedProductIds = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FoodItem> get _filteredProducts {
    if (_searchQuery.isEmpty) {
      return _allProducts;
    }
    return _allProducts
        .where(
          (item) =>
              item.name.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  List<FoodItem> get _dislikedItems {
    return _allProducts
        .where((item) => _dislikedProductIds.contains(item.id))
        .toList();
  }

  void _toggleDislike(String productId) {
    setState(() {
      if (_dislikedProductIds.contains(productId)) {
        _dislikedProductIds.remove(productId);
      } else {
        _dislikedProductIds.add(productId);
      }
    });
  }

  void _removeDislike(String productId) {
    setState(() {
      _dislikedProductIds.remove(productId);
    });
  }

  Future<void> _handleNext() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    // Convert to list of food names for the API
    final dislikedNames = _dislikedItems.map((item) => item.name).toList();

    // Save to provider
    ref.read(dietaryRefProvider.notifier).setDislikesIngredients(dislikedNames);

    // Simulate brief API delay for visual feedback
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    // Navigate to next step
    context.push('/select-activity-level');
  }

  void _handleBack() {
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: SafeArea(
        child: Column(
          children: [
            // Top section with progress bar and title
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Multi-step progress bar
                  Row(
                    children: [
                      _buildProgressSegment(const Color(0xFFFF9800), isActive: true),
                      const SizedBox(width: 4),
                      _buildProgressSegment(const Color(0xFFFF9800), isActive: true),
                      const SizedBox(width: 4),
                      _buildProgressSegment(const Color(0xFFFF9800), isActive: true),
                      const SizedBox(width: 4),
                      _buildProgressSegment(const Color(0xFFFF9800), isActive: false),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Title
                  const Text(
                    'Dislikes',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subtitle
                  const Text(
                    'Let us know what foods you dislike or don\'t eat',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF666666),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Color(0xFF000000)),
                      decoration: InputDecoration(
                        hintText: 'All products',
                        hintStyle: TextStyle(color: Color(0xFF000000)),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Color(0xFF000000),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Main scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // "Not my taste" section
                    if (_dislikedItems.isNotEmpty) ...[
                      const Text(
                        'Not my taste',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _dislikedItems.map((item) {
                          return _buildFoodChip(
                            item: item,
                            isSelected: true,
                            onTap: () => _removeDislike(item.id),
                            showRemoveIcon: true,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],
                    // "Common products" section
                    const Text(
                      'Common products',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _filteredProducts.map((item) {
                        final isDisliked = _dislikedProductIds.contains(
                          item.id,
                        );
                        return _buildFoodChip(
                          item: item,
                          isSelected: isDisliked,
                          onTap: () => _toggleDislike(item.id),
                          showRemoveIcon: false,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 100), // Space for bottom nav
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Bottom navigation bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Back button
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: _isSubmitting ? null : _handleBack,
                ),
              ),
              const SizedBox(width: 16),
              // Next button
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800), // Dark navy
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Next',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSegment(Color color, {required bool isActive}) {
    return Expanded(
      child: Container(
        height: 8,
        decoration: BoxDecoration(
          color: isActive ? color : color.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildFoodChip({
    required FoodItem item,
    required bool isSelected,
    required VoidCallback onTap,
    required bool showRemoveIcon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF9800) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(item.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              item.name,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isSelected ? const Color(0xFFE65100) : Colors.black87,
              ),
            ),
            if (showRemoveIcon) ...[
              const SizedBox(width: 8),
              Icon(Icons.close, size: 18, color: Color(0xFF000000)),
            ],
          ],
        ),
      ),
    );
  }
}
