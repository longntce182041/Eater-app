import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/health_guide_models.dart';
import '../../data/health_guides_api.dart';
import '../../../../shared/providers/dio_provider.dart';

/// Provider for HealthGuidesAPI
final healthGuidesApiProvider = Provider<HealthGuidesAPI>((ref) {
  final dio = ref.watch(dioProvider);
  return HealthGuidesAPI(dio);
});

/// Fetch all health guides grouped by category
final allHealthGuidesProvider =
    FutureProvider<List<HealthGuideCategory>>((ref) async {
  final api = ref.watch(healthGuidesApiProvider);
  return api.getAllGuidesByCategory();
});

/// Fetch guides for a specific category
final guidesByCategoryProvider =
    FutureProvider.family<HealthGuideCategory, String>((ref, category) async {
  final api = ref.watch(healthGuidesApiProvider);
  return api.getGuidesByCategory(category: category);
});

/// Fetch single guide with full content
final guideDetailProvider =
    FutureProvider.family<HealthGuide, String>((ref, guideId) async {
  final api = ref.watch(healthGuidesApiProvider);
  return api.getGuideDetail(guideId: guideId);
});
