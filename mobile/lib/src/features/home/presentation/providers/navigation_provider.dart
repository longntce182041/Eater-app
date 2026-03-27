import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to manage navigation index in MainNavigationPage
final mainNavigationIndexProvider = StateProvider<int>((ref) => 0);
