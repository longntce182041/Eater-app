import 'package:flutter/material.dart';

class StepLayout extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onNext;
  final VoidCallback? onBack;
  final bool showBack;
  final GlobalKey<FormState>? formKey;
  final String nextLabel;

  const StepLayout({
    super.key,
    required this.title,
    required this.child,
    this.onNext,
    this.onBack,
    this.showBack = true,
    this.formKey,
    this.nextLabel = 'Next',
  });

  void _tryNext() {
    if (formKey == null || formKey!.currentState!.validate()) {
      onNext?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style:
                      Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(child: formKey != null ? Form(key: formKey, child: child) : child),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (showBack)
                    OutlinedButton(
                      onPressed: onBack,
                      child: const Text('Back'),
                    )
                  else
                    const SizedBox(width: 88),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _tryNext,
                    child: Text(nextLabel),
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
