import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/dietary_ref_provider.dart';

class ExclusionOption {
  final String id;
  final String title;
  final IconData icon;
  const ExclusionOption({
    required this.id,
    required this.title,
    required this.icon,
  });
}

class SelectAllergiesPage extends ConsumerStatefulWidget {
  const SelectAllergiesPage({super.key});

  @override
  ConsumerState<SelectAllergiesPage> createState() =>
      _SelectAllergiesPageState();
}

class _SelectAllergiesPageState extends ConsumerState<SelectAllergiesPage> {
  final List<ExclusionOption> _options = const [
    ExclusionOption(
      id: 'none',
      title: 'No food exclusions',
      icon: Icons.kitchen,
    ),
    ExclusionOption(
      id: 'lactose_free',
      title: 'Lactose-Free',
      icon: Icons.local_drink,
    ),
    ExclusionOption(id: 'gluten_free', title: 'Gluten-Free', icon: Icons.grass),
    ExclusionOption(id: 'nut_free', title: 'Nut-Free', icon: Icons.park),
    ExclusionOption(
      id: 'dairy_free',
      title: 'Dairy-Free',
      icon: Icons.icecream,
    ),
    ExclusionOption(
      id: 'shellfish_free',
      title: 'Shellfish-Free',
      icon: Icons.set_meal,
    ),
  ];

  final Set<String> _selected = {};

  bool get _hasSelection => _selected.isNotEmpty;

  void _toggleSelection(String id) {
    setState(() {
      if (id == 'none') {
        _selected
          ..clear()
          ..add('none');
      } else {
        if (_selected.contains('none')) {
          _selected.remove('none');
        }
        if (_selected.contains(id)) {
          _selected.remove(id);
        } else {
          _selected.add(id);
        }
      }
    });
  }

  void _handleNext() {
    if (!_hasSelection) return;
    // Map selected ids to display titles
    final selectedTitles = _options
        .where((opt) => _selected.contains(opt.id))
        .map((e) => e.title)
        .toList();

    ref.read(dietaryRefProvider.notifier).setAllergies(selectedTitles);
    context.push('/select-dislikes');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _OnboardingProgressBar(),
                  const SizedBox(height: 24),
                  const Text(
                    'Do you avoid any foods for faith or allergy reasons?',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _InfoCard(),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.builder(
                  itemCount: _options.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final option = _options[index];
                    final isSelected = _selected.contains(option.id);
                    return _ExclusionTile(
                      option: option,
                      isSelected: isSelected,
                      onTap: () => _toggleSelection(option.id),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
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
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () => context.pop(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _hasSelection ? _handleNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey,
                    elevation: 0,
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingProgressBar extends StatelessWidget {
  const _OnboardingProgressBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _ProgressSegment(color: Color(0xFFFF9800), isActive: true),
        SizedBox(width: 6),
        _ProgressSegment(color: Color(0xFFFF9800), isActive: true),
        SizedBox(width: 6),
        _ProgressSegment(color: Color(0xFFFF9800), isActive: true),
        SizedBox(width: 6),
        _ProgressSegment(color: Color(0xFFFF9800), isActive: true),
        SizedBox(width: 6),
        _ProgressSegment(color: Color(0xFFFF9800), isActive: false),
      ],
    );
  }
}

class _ProgressSegment extends StatelessWidget {
  final Color color;
  final bool isActive;
  const _ProgressSegment({required this.color, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 8,
        decoration: BoxDecoration(
          color: isActive ? color : color.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.emoji_food_beverage,
              size: 32,
              color: Color(0xFFFF9800),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Behind the question',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'We screen every recipe for ...',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'More',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExclusionTile extends StatelessWidget {
  final ExclusionOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _ExclusionTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF3E0) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        option.icon,
                        color: const Color(0xFFFF9800),
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFF9800), width: 2),
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 18,
                    color: Color(0xFFFF9800),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
