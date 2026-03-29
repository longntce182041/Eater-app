import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/health_guide_models.dart';
import '../../data/health_guides_api.dart';
import '../../../../shared/providers/dio_provider.dart';

/// 🎯 HEALTH GUIDES PROVIDERS
///
/// Riverpod state management for health guides feature:
/// - healthGuidesApiProvider: Provides HealthGuidesAPI instance
/// - allHealthGuidesProvider: Fetch all guides grouped by category
/// - guidesByCategoryProvider: Lazy-load guides for specific category (family provider)
/// - guideDetailProvider: Fetch single guide with full content (family provider)
///
/// Architecture:
/// - FutureProviders for data fetching (read-only, no mutations)
/// - Family providers for parameterized requests
/// - Single API client instance shared across all providers
///
/// Usage Pattern:
/// ```dart
/// // In HealthGuidesScreen
/// final allGuidesAsync = ref.watch(allHealthGuidesProvider);
/// allGuidesAsync.when(
///   loading: () => Spinner,
///   error: (err) => ErrorUI,
///   data: (categories) => DisplayCategories
/// );
///
/// // In GuideDetailSheet
/// final guideAsync = ref.watch(guideDetailProvider('guide_123'));
/// guideAsync.when(
///   loading: () => Spinner,
///   error: (err) => ErrorUI,
///   data: (guide) => DisplayContent
/// );
/// ```

/// 🔌 Health Guides API Client Provider
///
/// Initializes HealthGuidesAPI with authenticated Dio client
/// Watches dioProvider - rebuilds if authentication changes
///
/// Used by: All data fetching providers
final healthGuidesApiProvider = Provider<HealthGuidesAPI>((ref) {
  final dio = ref.watch(dioProvider);
  return HealthGuidesAPI(dio);
});

/// 📚 All Health Guides Grouped by Category
///
/// Fetches all available guides grouped by category from backend
///
/// Endpoint: GET /api/health-guides
///
/// Flow:
/// 1. User opens Health Guides screen
/// 2. ref.watch(allHealthGuidesProvider) triggers API request
/// 3. Returns List<HealthGuideCategory>
/// 4. HealthGuidesScreen displays categories as tabs
/// 5. User selects category → display guides in that category
///
/// State:
/// - AsyncValue.loading: Initial load or refresh
/// - AsyncValue.error: API error (network, 5xx, etc.)
/// - AsyncValue.data: Successfully loaded categories
///
/// Used by: HealthGuidesScreen (main guides browsing)
///
/// Example Response:
/// ```
/// [
///   HealthGuideCategory(
///     category: "fasting",
///     guides: [guide1, guide2, ...]
///   ),
///   HealthGuideCategory(
///     category: "nutrition",
///     guides: [guide3, guide4, ...]
///   ),
///   ...
/// ]
/// ```
///
/// Rebuild Triggers:
/// - Manual: ref.refresh(allHealthGuidesProvider)
/// - Auth change: dioProvider invalidated
/// - Never: Cache persists until explicitly invalidated
final allHealthGuidesProvider =
    FutureProvider<List<HealthGuideCategory>>((ref) async {
  final api = ref.watch(healthGuidesApiProvider);
  return api.getAllGuidesByCategory();
});

/// 🔍 Guides by Category (Lazy-Load)
///
/// Family provider: Fetch guides for specific category
/// Allows lazy-loading instead of fetching all upfront
///
/// Endpoint: GET /api/health-guides?category=:category
///
/// Parameters:
/// - category: Category identifier (fasting, nutrition, workouts, etc.)
///
/// Flow:
/// 1. User opens Health Guides (loads allHealthGuidesProvider)
/// 2. User clicks category tab
/// 3. ref.watch(guidesByCategoryProvider(category)) triggers
/// 4. Fetches guides only for selected category
/// 5. Displays in list
///
/// State:
/// - AsyncValue.loading: Fetching category guides
/// - AsyncValue.error: API error
/// - AsyncValue.data: Successfully loaded category data
///
/// Returns: HealthGuideCategory
/// - Single category with filtered guides
///
/// Example Usage:
/// ```dart
/// // Watch guides for fasting category
/// final fastingAsync = ref.watch(guidesByCategoryProvider('fasting'));
/// fastingAsync.when(
///   data: (category) => ListView.builder(
///     itemCount: category.guides.length,
///     itemBuilder: (context, index) => GuideCard(
///       guide: category.guides[index],
///     ),
///   ),
/// );
/// ```
///
/// Key Benefit:
/// - If user selected fasting category, only fetch fasting guides
/// - Reduces bandwidth for large guide libraries
/// - Parallel requests: Can fetch multiple categories simultaneously
final guidesByCategoryProvider =
    FutureProvider.family<HealthGuideCategory, String>((ref, category) async {
  final api = ref.watch(healthGuidesApiProvider);
  return api.getGuidesByCategory(category: category);
});

/// 📖 Single Guide Detail with Full Content
///
/// Family provider: Fetch single guide by ID with full content
/// Fetched on-demand when user taps guide card
///
/// Endpoint: GET /api/health-guides/:guideId
///
/// Parameters:
/// - guideId: Unique guide identifier
///
/// Flow:
/// 1. User taps GuideCard in HealthGuidesScreen
/// 2. showModalBottomSheet(GuideDetailSheet(guideId))
/// 3. GuideDetailSheet: ref.watch(guideDetailProvider(guideId))
/// 4. Fetches full guide content from backend
/// 5. Displays in bottom sheet
///
/// State:
/// - AsyncValue.loading: Fetching guide content
/// - AsyncValue.error: API error (guide not found, network error)
/// - AsyncValue.data: Successfully loaded guide with content
///
/// Returns: HealthGuide
/// - Complete guide with all fields populated
/// - content field contains full article text
///
/// What's Loaded:
/// - title, description, content (full article)
/// - tags (keyword labels)
/// - difficulty (beginner/intermediate/advanced)
/// - estimatedReadTime (in minutes)
/// - category, icon, etc.
///
/// Example Usage:
/// ```dart
/// // In GuideDetailSheet
/// final guideAsync = ref.watch(guideDetailProvider(guideId));
///
/// guideAsync.when(
///   loading: () => Center(child: CircularProgressIndicator()),
///   error: (err, _) => ErrorUI,
///   data: (guide) => SingleChildScrollView(
///     child: Column(
///       children: [
///         Text(guide.title),
///         Text(guide.content),
///       ],
///     ),
///   ),
/// );
/// ```
///
/// Caching:
/// - Riverpod caches results by guideId
/// - Multiple views requesting same guide returns cached data
/// - Cache cleared if: User navigates away, app backgrounded (optional)
///
/// Performance:
/// - Separate API request per guide (not included in initial load)
/// - Avoids fetching large content for guides user won't read
/// - Parallel requests possible if user opens multiple guides
final guideDetailProvider =
    FutureProvider.family<HealthGuide, String>((ref, guideId) async {
  final api = ref.watch(healthGuidesApiProvider);
  return api.getGuideDetail(guideId: guideId);
});
