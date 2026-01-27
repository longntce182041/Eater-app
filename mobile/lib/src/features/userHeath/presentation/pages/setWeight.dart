import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/profile_setup_provider.dart';

class SetWeightPage extends ConsumerStatefulWidget {
  const SetWeightPage({super.key});

  @override
  ConsumerState<SetWeightPage> createState() => _SetWeightPageState();
}

class _SetWeightPageState extends ConsumerState<SetWeightPage> {
  late TextEditingController _weightController;
  String _selectedGoal = 'maintain';

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(text: '70.0');
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    final weight = double.tryParse(_weightController.text);
    if (weight == null || weight < 30 || weight > 300) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid weight (30-300 kg)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final userId = ref.read(profileSetupProvider('')).data.userId ?? '';
    ref.read(profileSetupProvider(userId).notifier).setWeight(weight);
    ref
        .read(profileSetupProvider(userId).notifier)
        .setWeightGoal(_selectedGoal);
    context.push('/set-gender');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Weight & Goal',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tell us about your weight',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 40),

              // Weight Input
              const Text(
                'Current Weight (kg)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Enter your weight',
                  suffix: const Text('kg'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                style: const TextStyle(fontSize: 18),
              ),

              const SizedBox(height: 32),

              // Weight Goal
              const Text(
                'Weight Goal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 12),

              _buildGoalOption('lose', 'Lose Weight', Icons.trending_down),
              const SizedBox(height: 12),
              _buildGoalOption(
                'maintain',
                'Maintain Weight',
                Icons.horizontal_rule,
              ),
              const SizedBox(height: 12),
              _buildGoalOption('gain', 'Gain Weight', Icons.trending_up),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Continue',
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

  Widget _buildGoalOption(String value, String label, IconData icon) {
    final isSelected = _selectedGoal == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedGoal = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF9800) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFFF9800) : Colors.grey[600],
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: const Color(0xFF2D2D2D),
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFFFF9800)),
          ],
        ),
      ),
    );
  }
}
