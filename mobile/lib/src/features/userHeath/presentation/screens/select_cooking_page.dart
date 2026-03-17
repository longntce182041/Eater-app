import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/dietary_ref_provider.dart';

class CookingSkillOption {
  final String id;
  final String title;
  final String subtitle;
  final String? description;
  final IconData icon;

  const CookingSkillOption({
    required this.id,
    required this.title,
    required this.subtitle,
    this.description,
    required this.icon,
  });
}

class SelectCookingPage extends ConsumerStatefulWidget {
  const SelectCookingPage({super.key});

  @override
  ConsumerState<SelectCookingPage> createState() => _SelectCookingPageState();
}

class _SelectCookingPageState extends ConsumerState<SelectCookingPage> {
  final List<CookingSkillOption> _options = const [
    CookingSkillOption(
      id: 'beginner',
      title: 'Beginner',
      subtitle: '"I can cook sandwich"',
      icon: Icons.lunch_dining,
    ),
    CookingSkillOption(
      id: 'beginner',
      title: 'Basic',
      subtitle: '"I cook only simple recipes"',
      description:
          "You're on your way! We'll help you develop your skills with easy recipes",
      icon: Icons.ramen_dining,
    ),
    CookingSkillOption(
      id: 'intermediate',
      title: 'Intermediate',
      subtitle: '"I regularly try new recipes"',
      icon: Icons.set_meal,
    ),
    CookingSkillOption(
      id: 'advanced',
      title: 'Advanced',
      subtitle: '"I can cook any recipe"',
      icon: Icons.rice_bowl,
    ),
  ];

  String? _selectedId;

  void _onSelect(String id) {
    setState(() => _selectedId = id);
  }

  void _onNext() {
    if (_selectedId == null) return;
    ref.read(dietaryRefProvider.notifier).setCookingSkillLevel(_selectedId!);
    context.push('/select-cooking-time');
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
                children: const [
                  _OnboardingProgressBar(),
                  SizedBox(height: 24),
                  Text(
                    'How would you rate your cooking skills?',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 16),
                  _InfoCard(),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _options.length,
                itemBuilder: (context, index) {
                  final opt = _options[index];
                  final isSelected = opt.id == _selectedId;
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == _options.length - 1 ? 120 : 16,
                    ),
                    child: _CookingSkillCard(
                      option: opt,
                      isSelected: isSelected,
                      onTap: () => _onSelect(opt.id),
                    ),
                  );
                },
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
                  onPressed: _selectedId == null ? null : _onNext,
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
                  'Your skill level lets us match ...',
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

class _CookingSkillCard extends StatelessWidget {
  final CookingSkillOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _CookingSkillCard({
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
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          option.subtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF000000),
                          ),
                        ),
                        if (option.description != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            option.description!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(option.icon, size: 28, color: const Color(0xFFFF9800)),
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
