import 'package:flutter/material.dart';
import '../../../core/utils/notification_service.dart';

class ActivityLevelOption {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;

  const ActivityLevelOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class ActivityLevelScreen extends StatefulWidget {
  const ActivityLevelScreen({super.key});

  @override
  State<ActivityLevelScreen> createState() => _ActivityLevelScreenState();
}

class _ActivityLevelScreenState extends State<ActivityLevelScreen> {
  final List<ActivityLevelOption> _levels = const [
    ActivityLevelOption(
      id: 'sedentary',
      title: 'Not very active',
      subtitle: 'Sedentary lifestyle, little or no exercise',
      icon: Icons.chair_alt,
    ),
    ActivityLevelOption(
      id: 'light',
      title: 'Lightly active',
      subtitle: 'Light exercise 1–3 days per week',
      icon: Icons.self_improvement,
    ),
    ActivityLevelOption(
      id: 'moderate',
      title: 'Moderately active',
      subtitle: 'Moderate exercise 3–5 days per week',
      icon: Icons.directions_run,
    ),
    ActivityLevelOption(
      id: 'active',
      title: 'Very active',
      subtitle: 'Hard exercise or physical job most days',
      icon: Icons.fitness_center,
    ),
    ActivityLevelOption(
      id: 'very active',
      title: 'Extremely active',
      subtitle: 'Athlete or very physically demanding job',
      icon: Icons.auto_awesome_motion,
    ),
  ];

  String? _selectedLevelId;
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (_selectedLevelId == null) {
      NotificationService.showWarning(
        context,
        message: 'Please choose your activity level.',
      );
      return;
    }
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);
    await submitActivityLevel(_selectedLevelId!);
    if (!mounted) return;

    setState(() => _isSubmitting = false);
    Navigator.pushNamed(context, '/onboarding/next-step');
  }

  void _select(String id) {
    if (_isSubmitting) return;
    setState(() {
      _selectedLevelId = id;
    });
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
                  const OnboardingProgressBar(),
                  const SizedBox(height: 24),
                  const Text(
                    'How active\nare you each day?',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _InfoCard(),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _levels.length,
                itemBuilder: (context, index) {
                  final level = _levels[index];
                  final isSelected = level.id == _selectedLevelId;
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == _levels.length - 1 ? 120 : 16,
                    ),
                    child: ActivityLevelCard(
                      option: level,
                      isSelected: isSelected,
                      onTap: () => _select(level.id),
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
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF000000)),
                  onPressed: _isSubmitting
                      ? null
                      : () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: (_selectedLevelId == null || _isSubmitting)
                      ? null
                      : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey,
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
}

class OnboardingProgressBar extends StatelessWidget {
  const OnboardingProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _ProgressSegment(color: Colors.green, isActive: true),
        SizedBox(width: 6),
        _ProgressSegment(color: Colors.yellow, isActive: true),
        SizedBox(width: 6),
        _ProgressSegment(color: Colors.orange, isActive: true),
        SizedBox(width: 6),
        _ProgressSegment(color: Colors.deepOrange, isActive: true),
        SizedBox(width: 6),
        _ProgressSegment(color: Colors.deepOrange, isActive: false),
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
        color: const Color(0xFFF4C99E),
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
              Icons.travel_explore,
              size: 32,
              color: Colors.deepOrange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'About this question',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Your activity level helps us personalize your plan ...',
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
            'Learn more',
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

class ActivityLevelCard extends StatelessWidget {
  final ActivityLevelOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const ActivityLevelCard({
    super.key,
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
          color: isSelected ? const Color(0xFFFCE8D8) : Colors.white,
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
                            color: Colors.black54,
                          ),
                        ),
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
                    child: Icon(
                      option.icon,
                      size: 28,
                      color: Colors.deepOrange,
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
                    border: Border.all(color: Colors.deepOrange, width: 2),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.deepOrange,
                    size: 18,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Future<void> submitActivityLevel(String levelId) async {
  await Future.delayed(const Duration(milliseconds: 500));
}
