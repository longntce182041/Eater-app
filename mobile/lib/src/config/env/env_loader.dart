import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

import 'app_config.dart';

class EnvLoader {
  static AppConfig load() {
    // Default to iOS/macOS simulator using localhost.
    // For Android emulator, 10.0.2.2 points to host machine.
    String base = 'http://localhost:3000';

    if (!kIsWeb) {
      try {
        final isAndroid = Platform.isAndroid;
        base = isAndroid ? 'http://10.0.2.2:3000' : 'http://localhost:3000';
      } catch (e) {
        // Platform access not supported in this context (e.g., tests)
        // Default to localhost
      }
    }

    return AppConfig(apiBaseUrl: base);
  }
}
