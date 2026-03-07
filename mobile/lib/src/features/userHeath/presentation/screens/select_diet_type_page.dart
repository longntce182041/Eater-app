import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/dietary_ref_provider.dart';
import '../../../home/domain/profile_models.dart';

class SelectDietTypePage extends ConsumerStatefulWidget {
  const SelectDietTypePage({super.key});

  @override
  ConsumerState<SelectDietTypePage> createState() => _SelectDietTypePageState();
}

class _SelectDietTypePageState extends ConsumerState<SelectDietTypePage> {
  String? _selectedDietTypeId;
  bool _isSubmitting = false;

  Future<void> _selectDiet(String dietId) async {
    if (_isSubmitting) return;

    setState(() {
      _selectedDietTypeId = dietId;
      _isSubmitting = true;
    });

    // Save to provider
    ref.read(dietaryRefProvider.notifier).setDietType(dietId);

    // Simulate brief delay for visual feedback
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    // Navigate to next step
    setState(() => _isSubmitting = false);
    context.push('/select-allergies');
  }

  @override
  Widget build(BuildContext context) {
    final dietTypesAsync = ref.watch(dietTypesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar section
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Multi-step progress bar
                  Row(
                    children: [
                      _buildProgressSegment(const Color(0xFFFF9800), isActive: true),
                      const SizedBox(width: 4),
                      _buildProgressSegment(const Color(0xFFFF9800), isActive: false),
                      const SizedBox(width: 4),
                      _buildProgressSegment(const Color(0xFFFF9800), isActive: false),
                      const SizedBox(width: 4),
                      _buildProgressSegment(const Color(0xFFFF9800), isActive: false),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Title
                  const Text(
                    'Select your diet',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subtitle
                  const Text(
                    'Which diet best fits your preferences?',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Diet cards list
            Expanded(
              child: dietTypesAsync.when(
                data: (dietTypes) {
                  if (dietTypes.isEmpty) {
                    return const Center(
                      child: Text(
                        'No diet types available',
                        style: TextStyle(color: Colors.black54),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    itemCount: dietTypes.length,
                    itemBuilder: (context, index) {
                      final dietType = dietTypes[index];
                      final isSelected = _selectedDietTypeId == dietType.id;

                      return _buildDietCard(
                        dietType: dietType,
                        isSelected: isSelected,
                        onTap: () => _selectDiet(dietType.id),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF9800)),
                  ),
                ),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load diet types',
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(dietTypesProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
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

  Widget _buildDietCard({
    required DietTypeModel dietType,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: _isSubmitting ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF3E0) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Left side - Text content
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Diet name
                        Text(
                          dietType.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.black87 : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Description
                        Text(
                          dietType.description ?? 'No description',
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected ? Colors.black54 : Colors.black54,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        // Macro ratios (if available)
                        if (dietType.carbRatio != null &&
                            dietType.proteinRatio != null &&
                            dietType.fatRatio != null)
                          Text(
                            'Carbs ${(dietType.carbRatio! * 100).toInt()}% • '
                            'Protein ${(dietType.proteinRatio! * 100).toInt()}% • '
                            'Fat ${(dietType.fatRatio! * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? Colors.black45
                                  : Colors.black45,
                            ),
                          ),
                        const SizedBox(height: 12),
                        // View diet link
                        Row(
                          children: [
                            Text(
                              'View diet',
                              style: TextStyle(
                                fontSize: 14,
                                color: isSelected
                                    ? const Color(0xFFE65100)
                                    : Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right,
                              size: 18,
                              color: isSelected
                                  ? const Color(0xFFE65100)
                                  : Colors.grey[600],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Right side - Image
                  Expanded(
                    flex: 2,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          color: Colors.grey[200],
                          child: Image.network(
                            'https://via.placeholder.com/150/9C27B0/FFFFFF?text=${dietType.name[0]}',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.restaurant,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Checkmark indicator when selected
            if (isSelected)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFF9800), width: 2),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Color(0xFFFF9800),
                    size: 20,
                  ),
                ),
              ),
            // Loading indicator overlay
            if (_isSubmitting && isSelected)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF9800)),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
