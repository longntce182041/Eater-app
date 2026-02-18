import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/dietary_ref_provider.dart';

class SelectCookingTimePage extends ConsumerStatefulWidget {
  const SelectCookingTimePage({super.key});

  @override
  ConsumerState<SelectCookingTimePage> createState() =>
      _SelectCookingTimePageState();
}

class _SelectCookingTimePageState extends ConsumerState<SelectCookingTimePage> {
  final List<Map<String, dynamic>> _timeOptions = [
    {
      'value': 15,
      'label': '15 minutes',
      'subtitle': 'Quick & easy meals',
      'icon': Icons.flash_on,
    },
    {
      'value': 30,
      'label': '30 minutes',
      'subtitle': 'Balanced preparation time',
      'icon': Icons.timer,
    },
    {
      'value': 45,
      'label': '45 minutes',
      'subtitle': 'More elaborate dishes',
      'icon': Icons.restaurant,
    },
    {
      'value': 60,
      'label': '1 hour',
      'subtitle': 'Complex recipes',
      'icon': Icons.kitchen,
    },
    {
      'value': 90,
      'label': '1.5+ hours',
      'subtitle': 'Gourmet cooking',
      'icon': Icons.star,
    },
  ];

  int? _selectedTime;
  String? _validationError;

  bool _validate() {
    if (_selectedTime == null) {
      setState(() {
        _validationError = 'Please select your available cooking time';
      });
      return false;
    }
    setState(() {
      _validationError = null;
    });
    return true;
  }

  void _continue() {
    if (_validate()) {
      ref
          .read(dietaryRefProvider.notifier)
          .setAvailableCookingTime(_selectedTime!);
      context.push('/select-calories');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6D9F5),
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
                    'How much time can you spend cooking?',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
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
                itemCount: _timeOptions.length,
                itemBuilder: (context, index) {
                  final option = _timeOptions[index];
                  final isSelected = _selectedTime == option['value'];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == _timeOptions.length - 1 ? 120 : 16,
                    ),
                    child: _CookingTimeCard(
                      time: option['value'] as int,
                      label: option['label'] as String,
                      subtitle: option['subtitle'] as String,
                      icon: option['icon'] as IconData,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          _selectedTime = option['value'] as int;
                          _validationError = null;
                        });
                      },
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
          color: Colors.white.withOpacity(0.95),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_validationError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _validationError!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              Row(
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
                      onPressed: _selectedTime == null ? null : _continue,
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
                      child: const Text(
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
        _ProgressSegment(color: Colors.green, isActive: true),
        SizedBox(width: 6),
        _ProgressSegment(color: Colors.yellow, isActive: true),
        SizedBox(width: 6),
        _ProgressSegment(color: Colors.orange, isActive: true),
        SizedBox(width: 6),
        _ProgressSegment(color: Colors.purple, isActive: true),
        SizedBox(width: 6),
        _ProgressSegment(color: Colors.purple, isActive: true),
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
          color: isActive ? color : color.withOpacity(0.3),
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
        color: const Color(0xFFD4C4ED),
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
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.schedule, size: 32, color: Colors.purple),
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
                  'We\'ll suggest recipes that fit your schedule',
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
        ],
      ),
    );
  }
}

class _CookingTimeCard extends StatelessWidget {
  final int time;
  final String label;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CookingTimeCard({
    required this.time,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD4C4ED) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.purple.withOpacity(0.2)
                      : Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: isSelected ? Colors.purple[700] : Colors.grey[700],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: Colors.purple, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}
