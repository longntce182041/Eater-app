import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/home_dashboard_api_client.dart';
import '../../domain/home_dashboard_models.dart';
import '../../../../shared/providers/app_config_provider.dart';
import '../../../../shared/providers/dio_provider.dart';

/// 📊 HOME DASHBOARD PROVIDERS
///
/// This file provides Riverpod providers for managing home dashboard state:
/// - API client initialization
/// - Dashboard data fetching
/// - Upcoming meals fetching
/// - Refresh functionality

/// 🔌 API Client Provider
///
/// Initializes HomeDashboardApiClient with:
/// - Dio HTTP client (from dioProvider)
/// - API base URL (from appConfigProvider)
///
/// Rebuilds when: Authentication changes, app config changes
final homeDashboardApiClientProvider = Provider<HomeDashboardApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  final config = ref.watch(appConfigProvider);
  return HomeDashboardApiClient(dio, config.apiBaseUrl);
});

/// 📈 Home Dashboard Provider
///
/// Fetches dashboard data including:
/// - User's daily calorie progress
/// - Macro nutrients breakdown (protein, carbs, fats)
/// - Today's meal list
/// - User stats (weight, BMI, etc.)
///
/// Usage: ref.watch(homeDashboardProvider)
///
/// Returns: `AsyncValue<HomeDashboardData>`
/// - loading: ⏳ First load
/// - data: ✅ Dashboard data loaded
/// - error: ❌ API or parsing error
final homeDashboardProvider = FutureProvider<HomeDashboardData>((ref) async {
  final apiClient = ref.watch(homeDashboardApiClientProvider);
  return apiClient.getHomeDashboard();
});

/// 📅 Upcoming Meals Provider
///
/// Fetches meals for the next N days
///
/// Parameters:
/// - days: Number of days ahead to fetch (1-30)
///
/// Usage: ref.watch(upcomingMealsProvider(7))
///
/// Returns: `AsyncValue<UpcomingMealsData>`
/// - Meals grouped by date
/// - Nutrition totals per day
final upcomingMealsProvider =
    FutureProvider.family<UpcomingMealsData, int>((ref, days) async {
  final apiClient = ref.watch(homeDashboardApiClientProvider);
  return apiClient.getUpcomingMeals(days: days);
});

/// 📋 Upcoming Meals Default Provider (7 days)
///
/// Convenience provider that fetches next 7 days of meals
/// Equivalent to: upcomingMealsProvider(7)
///
/// Usage: ref.watch(upcomingMealsDefaultProvider)
final upcomingMealsDefaultProvider =
    FutureProvider<UpcomingMealsData>((ref) async {
  return ref.watch(upcomingMealsProvider(7).future);
});

/// 🔄 Refresh Home Dashboard Provider
///
/// Utility provider to refresh all home dashboard data
///
/// Flow:
/// 1. Invalidate homeDashboardProvider (mark stale)
/// 2. Invalidate upcomingMealsDefaultProvider (mark stale)
/// 3. Watch both futures to trigger API requests
/// 4. Wait for both requests to complete
/// 5. Clients watching these providers get fresh data
///
/// Usage:
/// ```dart
/// // In UI:
/// ref.read(refreshHomeDashboardProvider);
///
/// // Or in event handler:
/// await ref.read(refreshHomeDashboardProvider.future);
/// ```
final refreshHomeDashboardProvider = FutureProvider<void>((ref) async {
  ref.invalidate(homeDashboardProvider);
  ref.invalidate(upcomingMealsDefaultProvider);
  await ref.watch(homeDashboardProvider.future);
  await ref.watch(upcomingMealsDefaultProvider.future);
});
