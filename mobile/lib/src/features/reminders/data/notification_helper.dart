// Conditional export: picks the right implementation per platform.
// - Android/native  → notification_helper_stub.dart  (no-ops)
// - Web (Chrome)    → notification_helper_web.dart   (Browser Notification API)
export 'notification_helper_stub.dart'
    if (dart.library.html) 'notification_helper_web.dart';
