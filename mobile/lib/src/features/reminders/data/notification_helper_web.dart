import 'dart:async';
import 'dart:js_interop';

// Direct JS binding — bypasses package:web to avoid any extension type issues.
@JS('Notification')
extension type _Notif._(JSObject _) {
  external factory _Notif(String title, JSObject options);
  external static String get permission;
  external static JSPromise<JSString> requestPermission();
}

/// Active timers per mealType (web-only, lives for the browser session).
final _timers = <String, List<Timer>>{};

/// No-op on startup — Chrome requires a user gesture to show the permission dialog.
Future<void> initWebNotifications() async {}

/// Schedule browser notifications for [mealType] on the specified [days]
/// at [hour]:[minute] (local time).
Future<void> scheduleWebReminders(
  String mealType,
  List<int> days,
  int hour,
  int minute,
  String title,
  String body,
) async {
  if (_Notif.permission == 'default') {
    await _Notif.requestPermission().toDart;
  }
  if (_Notif.permission != 'granted') return;

  cancelWebReminders(mealType);
  final now = DateTime.now();
  final timers = <Timer>[];

  for (final day in days) {
    final next = _nextOccurrence(day, hour, minute);
    final delay = next.difference(now);
    if (delay.inSeconds <= 0) continue;
    timers.add(Timer(delay, () => _show(title, body)));
  }

  if (timers.isNotEmpty) _timers[mealType] = timers;
}

void _show(String title, String body) {
  if (_Notif.permission != 'granted') return;
  try {
    final opts = {'body': body, 'icon': '/favicon.png'}.jsify() as JSObject;
    _Notif(title, opts);
  } catch (e) {
    // Print to browser DevTools console for debugging
    _consoleError('Notification error: $e'.toJS);
  }
}

@JS('console.error')
external void _consoleError(JSAny? message);

/// Cancel all pending timers for [mealType].
void cancelWebReminders(String mealType) {
  for (final t in (_timers[mealType] ?? [])) {
    t.cancel();
  }
  _timers.remove(mealType);
}

/// Cancel all pending notification timers.
void cancelAllWebReminders() {
  for (final list in _timers.values) {
    for (final t in list) {
      t.cancel();
    }
  }
  _timers.clear();
}

/// Fire a notification immediately — for testing only.
Future<void> showInstantWebNotification(String title, String body) async {
  if (_Notif.permission == 'default') {
    await _Notif.requestPermission().toDart;
  }
  _show(title, body);
}

/// Returns current browser notification permission: 'granted', 'denied', or 'default'.
String getWebPermissionStatus() => _Notif.permission;

/// Returns the next [DateTime] (local time) matching the given weekday + time.
/// [dayOfWeek]: 0=Sunday … 6=Saturday (matches our model convention).
DateTime _nextOccurrence(int dayOfWeek, int hour, int minute) {
  final isoTarget = dayOfWeek == 0 ? 7 : dayOfWeek;
  final now = DateTime.now();
  var candidate = DateTime(now.year, now.month, now.day, hour, minute);

  for (int i = 0; i < 8; i++) {
    if (candidate.weekday == isoTarget && candidate.isAfter(now)) {
      return candidate;
    }
    candidate = candidate.add(const Duration(days: 1));
  }
  return candidate;
}
