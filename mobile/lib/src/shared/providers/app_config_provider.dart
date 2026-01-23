import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/env/app_config.dart';

final appConfigProvider = Provider<AppConfig>((ref) {
  // TODO: Load from env or flavor config.
  return const AppConfig(
    apiBaseUrl: 'https://api.example.com',
  );
});