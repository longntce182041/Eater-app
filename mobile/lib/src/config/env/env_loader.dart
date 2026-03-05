import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

import 'app_config.dart';

class EnvLoader {
  static AppConfig load() {
    String base = 'http://localhost:3000';

    if (kIsWeb) {
      // Running in web browser (Chrome, Safari, etc.)
      debugPrint('🌐 Platform: WEB BROWSER');
      base = 'http://localhost:3000';
    } else if (!kIsWeb) {
      try {
        final isAndroid = Platform.isAndroid;
        // Android emulator: 10.0.2.2 = host machine
        // iOS simulator: localhost works
        // Physical device: Need actual IP address
        base = isAndroid ? 'http://10.0.2.2:3000' : 'http://localhost:3000';
        debugPrint('🌐 Platform: ${isAndroid ? "Android" : "iOS/Other"}');
      } catch (e) {
        // Platform access not supported in this context (e.g., tests)
        debugPrint('🌐 Platform access failed, using default');
      }
    }

    debugPrint('🌐 API Base URL: $base');
    return AppConfig(apiBaseUrl: base);
  }
}
