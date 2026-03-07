import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/env/app_config.dart';
import '../../config/env/env_loader.dart';

final appConfigProvider = Provider<AppConfig>((ref) {
  return EnvLoader.load();
});
