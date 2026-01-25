import 'dart:io' show Platform;

import 'app_config.dart';

class EnvLoader {
  static AppConfig load() {
    // Default to iOS/macOS simulator using localhost.
    // For Android emulator, 10.0.2.2 points to host machine.
    final isAndroid = Platform.isAndroid;
    final base = isAndroid ? 'http://10.0.2.2:3000' : 'http://localhost:3000';
    return AppConfig(apiBaseUrl: base);
  }
}
