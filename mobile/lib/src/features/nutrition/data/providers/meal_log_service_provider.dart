import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/dio_provider.dart';
import '../services/meal_log_service.dart';

/// Provider for MealLogService
/// This service handles all API calls related to meal logging
final mealLogServiceProvider = Provider<MealLogService>((ref) {
  final dio = ref.watch(dioProvider);
  return MealLogService(dio: dio);
});
