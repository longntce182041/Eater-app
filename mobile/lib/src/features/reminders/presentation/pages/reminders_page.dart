import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/theme/app_colors.dart';
import '../../domain/reminder_model.dart';
import '../providers/reminder_provider.dart';

class RemindersPage extends ConsumerWidget {
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reminderProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Meal Reminders'),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _RemindersBody(reminders: state.reminders),
    );
  }
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

class _RemindersBody extends StatelessWidget {
  final List<ReminderModel> reminders;
  const _RemindersBody({required this.reminders});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // Header description
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.alarm_outlined,
                  color: AppColors.primary, size: 22),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Daily meal reminders help you maintain a more effective eating routine.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Reminder cards
        ...reminders.map((reminder) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ReminderCard(reminder: reminder),
            )),

        const SizedBox(height: 24),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Reminder Card
// ---------------------------------------------------------------------------

class _ReminderCard extends ConsumerWidget {
  final ReminderModel reminder;
  const _ReminderCard({required this.reminder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOn = reminder.enabled;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isOn ? 1.0 : 0.6,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOn
                ? AppColors.primary.withValues(alpha: 0.35)
                : Colors.grey.shade200,
            width: 1.5,
          ),
          boxShadow: isOn
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: icon + title + toggle
            Row(
              children: [
                _MealTypeIconWidget(mealType: reminder.mealType),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    reminder.displayLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Switch(
                  value: isOn,
                  activeThumbColor: AppColors.primary,
                  activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
                  onChanged: (_) => ref
                      .read(reminderProvider.notifier)
                      .toggleEnabled(reminder.mealType),
                ),
              ],
            ),

            // Time: tappable — opens time picker
            if (isOn) ...[
              const SizedBox(height: 4),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _pickTime(context, ref),
                child: Padding(
                  padding: const EdgeInsets.only(left: 36, top: 2, bottom: 6),
                  child: Row(
                    children: [
                      Text(
                        reminder.time,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.edit_outlined,
                          size: 14, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),

              // Day selector
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 36),
                child: _DaySelector(
                  selectedDays: reminder.days,
                  onChanged: (days) =>
                      ref.read(reminderProvider.notifier).saveReminder(
                            reminder.copyWith(days: days),
                          ),
                ),
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.only(left: 36, top: 2),
                child: Text(
                  reminder.time,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFBBBBBB),
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickTime(BuildContext context, WidgetRef ref) async {
    final parts = reminder.time.split(':');
    final initial = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      final newTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      ref.read(reminderProvider.notifier).saveReminder(
            reminder.copyWith(time: newTime),
          );
    }
  }
}

// ---------------------------------------------------------------------------
// Day Selector
// ---------------------------------------------------------------------------

class _DaySelector extends StatelessWidget {
  final List<int> selectedDays;
  final void Function(List<int>) onChanged;

  const _DaySelector({
    required this.selectedDays,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Day labels: index matches our convention (0=Sun, 1=Mon, ..., 6=Sat)
    const labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final isSelected = selectedDays.contains(i);
        return GestureDetector(
          onTap: () {
            final updated = List<int>.from(selectedDays);
            if (isSelected) {
              // Prevent deselecting all days
              if (updated.length > 1) updated.remove(i);
            } else {
              updated.add(i);
            }
            onChanged(updated);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppColors.primary : AppColors.primaryLight,
            ),
            alignment: Alignment.center,
            child: Text(
              labels[i],
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Meal Type Icon — cross-platform (no emoji, no Noto font warning)
// ---------------------------------------------------------------------------

class _MealTypeIconWidget extends StatelessWidget {
  final String mealType;
  const _MealTypeIconWidget({required this.mealType});

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color bg, Color fg) = switch (mealType) {
      'breakfast' => (Icons.wb_twilight_outlined,  const Color(0xFFFFF8E1), const Color(0xFFFFA000)),
      'lunch'     => (Icons.light_mode_outlined,    const Color(0xFFFFF3E0), const Color(0xFFFF9800)),
      'dinner'    => (Icons.nightlight_outlined,    const Color(0xFFE8EAF6), const Color(0xFF5C6BC0)),
      'snack'     => (Icons.local_cafe_outlined,    const Color(0xFFE8F5E9), const Color(0xFF388E3C)),
      _           => (Icons.alarm_outlined,          AppColors.primaryLight,  AppColors.primary),
    };

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, color: fg, size: 22),
    );
  }
}
