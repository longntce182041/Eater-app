import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/env/app_config.dart';

final appConfigProvider = Provider<AppConfig>((ref) {
  return const AppConfig(apiBaseUrl: 'http://localhost:3000');
});
