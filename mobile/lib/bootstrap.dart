import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz; // latest_all includes aliases (Asia/Saigon, etc.)
import 'package:timezone/timezone.dart' as tz;

import 'app.dart';
import 'src/features/reminders/data/notification_helper.dart';

/// Global notification plugin instance — accessible from anywhere in the app.
/// On web this instance exists but is never initialized, so all calls are no-ops.
final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize full timezone database (latest_all includes historical aliases)
  tz.initializeTimeZones();

  try {
    final tzInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzInfo.identifier));
  } catch (_) {
    // Fallback to UTC if device timezone cannot be resolved
    tz.setLocalLocation(tz.UTC);
  }

  // flutter_local_notifications only works on Android/iOS/macOS — skip on web
  if (!kIsWeb) {
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await flutterLocalNotificationsPlugin.initialize(initSettings);

    final androidImpl = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // Request POST_NOTIFICATIONS permission on Android 13+ (API 33+)
    await androidImpl?.requestNotificationsPermission();

    // Request Alarms & Reminders permission on Android 12 (API 31-32).
    // On Android 13+ this is auto-granted via USE_EXACT_ALARM in the manifest.
    await androidImpl?.requestExactAlarmsPermission();
  } else {
    // Request browser notification permission (Chrome / web)
    await initWebNotifications();
  }

  runApp(const ProviderScope(child: App()));
}
