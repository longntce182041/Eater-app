import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: Initialize env, logging, crash reporting, etc.

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}