import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../domain/reminder_model.dart';
import 'notification_helper.dart';

/// Notification channel for all meal reminders (Android).
const _androidChannel = AndroidNotificationDetails(
  'meal_reminders',
  'Meal Reminders',
  channelDescription: 'Daily meal time reminders to help you eat on schedule',
  importance: Importance.high,
  priority: Priority.high,
  icon: '@mipmap/ic_launcher',
);

/// Local notification scheduling service for mealtime reminders.
///
/// - Android : uses flutter_local_notifications (zonedSchedule)
/// - Web     : uses Browser Notification API via notification_helper_web.dart
///
/// Notification ID scheme (Android, avoids collision across 4 types × 7 days):
///   breakfast(0), lunch(1), dinner(2), snack(3)
///   ID = mealTypeIndex * 10 + dayOfWeek  (range 0–39)
class ReminderLocalService {
  final FlutterLocalNotificationsPlugin _plugin;

  ReminderLocalService(this._plugin);

  static const _mealTypeIndex = {
    'breakfast': 0,
    'lunch': 1,
    'dinner': 2,
    'snack': 3,
  };

  /// Schedule (or reschedule) repeating notifications for a reminder.
  /// Cancels any existing notifications for this meal type first.
  Future<void> scheduleReminder(ReminderModel reminder) async {
    await cancelReminder(reminder.mealType);
    if (!reminder.enabled || reminder.days.isEmpty) return;

    final parts = reminder.time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final title = '${reminder.icon} ${reminder.displayLabel}';
    final body = 'Time for ${reminder.displayLabel.toLowerCase()}! Remember to eat on time 🍽️';

    if (kIsWeb) {
      // Web: request permission + schedule via Browser Notification API.
      // scheduleWebReminders must be awaited so permission dialog can appear.
      await scheduleWebReminders(
        reminder.mealType,
        reminder.days,
        hour,
        minute,
        title,
        body,
      );
      return;
    }

    // Android: use flutter_local_notifications
    // Check if exact alarms are permitted (Android 12 requires user grant;
    // Android 13+ auto-grants via USE_EXACT_ALARM in the manifest).
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final canExact = (await androidImpl?.canScheduleExactNotifications()) ?? false;
    final scheduleMode = canExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexact;

    final idx = _mealTypeIndex[reminder.mealType] ?? 0;
    for (final day in reminder.days) {
      final notifId = idx * 10 + day;
      final scheduled = _nextOccurrence(day, hour, minute);

      await _plugin.zonedSchedule(
        notifId,
        title,
        body,
        scheduled,
        const NotificationDetails(android: _androidChannel),
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  /// Cancel all notifications for a given meal type.
  Future<void> cancelReminder(String mealType) async {
    if (kIsWeb) {
      cancelWebReminders(mealType);
      return;
    }
    final idx = _mealTypeIndex[mealType] ?? 0;
    for (int day = 0; day <= 6; day++) {
      await _plugin.cancel(idx * 10 + day);
    }
  }

  /// Cancel every scheduled reminder.
  Future<void> cancelAll() async {
    if (kIsWeb) {
      cancelAllWebReminders();
      return;
    }
    for (int id = 0; id < 40; id++) {
      await _plugin.cancel(id);
    }
  }

  /// Find the next [tz.TZDateTime] in local time matching [dayOfWeek] and [hour]:[minute].
  ///
  /// [dayOfWeek]: 0=Sunday, 1=Monday, ..., 6=Saturday (matching our model convention).
  tz.TZDateTime _nextOccurrence(int dayOfWeek, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);

    // Convert our day convention (0=Sun) to Dart's ISO weekday (1=Mon, 7=Sun)
    final isoTarget = dayOfWeek == 0 ? 7 : dayOfWeek;

    var candidate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    for (int i = 0; i < 8; i++) {
      if (candidate.weekday == isoTarget && candidate.isAfter(now)) {
        return candidate;
      }
      candidate = candidate.add(const Duration(days: 1));
    }

    return candidate;
  }
}
