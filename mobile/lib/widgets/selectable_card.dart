import 'package:flutter/material.dart';

class SelectableCard extends StatelessWidget {
  final bool selected;
  final Widget child;
  final VoidCallback onTap;

  const SelectableCard({super.key, required this.selected, required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = selected ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surfaceVariant;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? Theme.of(context).colorScheme.primary : Colors.transparent, width: 1.6),
        ),
        child: child,
      ),
    );
  }
}
