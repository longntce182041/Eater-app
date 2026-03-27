import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/home_dashboard_api_client.dart';
import '../../domain/home_dashboard_models.dart';
import '../../../../shared/providers/app_config_provider.dart';
import '../../../../shared/providers/dio_provider.dart';

/// Provider for the HomeDashboardApiClient
final homeDashboardApiClientProvider = Provider<HomeDashboardApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  final config = ref.watch(appConfigProvider);
  return HomeDashboardApiClient(dio, config.apiBaseUrl);
});

/// FutureProvider for home dashboard data
final homeDashboardProvider = FutureProvider<HomeDashboardData>((ref) async {
  final apiClient = ref.watch(homeDashboardApiClientProvider);
  return apiClient.getHomeDashboard();
});

/// FutureProvider for upcoming meals data
final upcomingMealsProvider =
    FutureProvider.family<UpcomingMealsData, int>((ref, days) async {
  final apiClient = ref.watch(homeDashboardApiClientProvider);
  return apiClient.getUpcomingMeals(days: days);
});

/// Convenience provider for upcoming meals with default 7 days
final upcomingMealsDefaultProvider =
    FutureProvider<UpcomingMealsData>((ref) async {
  return ref.watch(upcomingMealsProvider(7).future);
});

/// Provider to refresh home dashboard and upcoming meals
final refreshHomeDashboardProvider = FutureProvider<void>((ref) async {
  ref.invalidate(homeDashboardProvider);
  ref.invalidate(upcomingMealsDefaultProvider);
  await ref.watch(homeDashboardProvider.future);
  await ref.watch(upcomingMealsDefaultProvider.future);
});
