// Stub implementation for non-web platforms (Android, iOS, macOS, etc.).
// All methods are no-ops — native platforms use flutter_local_notifications instead.

Future<void> initWebNotifications() async {}

Future<void> scheduleWebReminders(
  String mealType,
  List<int> days,
  int hour,
  int minute,
  String title,
  String body,
) async {}

void cancelWebReminders(String mealType) {}

void cancelAllWebReminders() {}

/// Fire a notification immediately — for testing only. No-op on native.
Future<void> showInstantWebNotification(String title, String body) async {}

/// Returns current browser notification permission. Always 'granted' on native.
String getWebPermissionStatus() => 'granted';
