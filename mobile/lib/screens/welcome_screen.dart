import 'package:flutter/material.dart';
import '../widgets/step_layout.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onNext;
  const WelcomeScreen({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return StepLayout(
      title: 'Welcome',
      showBack: false,
      nextLabel: 'Get Started',
      onNext: onNext,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          // Placeholder for app logo
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(28)),
            child: const Center(child: Text('Logo', style: TextStyle(fontWeight: FontWeight.bold))),
          ),
          const SizedBox(height: 20),
          Text('Start your health journey', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Text('A simple plan tailored to you. Let\'s begin!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
        ],
      ),
    );
  }
}
