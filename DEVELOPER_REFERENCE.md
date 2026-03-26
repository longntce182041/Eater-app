# Mobile Home Experience - Developer Reference

## Quick Reference: Code Locations

### Backend Services

| Component            | File                                               | Key Methods                                    |
| -------------------- | -------------------------------------------------- | ---------------------------------------------- |
| Home Dashboard Logic | `src/api/services/home.dashboard.service.js`       | `getHomeDashboardData()`, `getUpcomingMeals()` |
| HTTP Handler         | `src/api/controllers/home.dashboard.controller.js` | `getHomeDashboard()`, `getUpcomingMeals()`     |
| Routes               | `src/api/routes/home.dashboard.routes.js`          | Registers `GET /api/home/*` endpoints          |

### Mobile Models

| Component   | File                                                        | Key Classes                                           |
| ----------- | ----------------------------------------------------------- | ----------------------------------------------------- |
| Data Models | `lib/src/features/home/domain/home_dashboard_models.dart`   | `HomeDashboardData`, `TodayMeal`, `UpcomingMealsData` |
| API Client  | `lib/src/features/home/data/home_dashboard_api_client.dart` | `HomeDashboardApiClient` class                        |

### Mobile State Management

| Component           | File                                                                        | Key Providers                                    |
| ------------------- | --------------------------------------------------------------------------- | ------------------------------------------------ |
| Dashboard Provider  | `lib/src/features/home/presentation/providers/home_dashboard_provider.dart` | `homeDashboardProvider`, `upcomingMealsProvider` |
| Navigation Provider | `lib/src/features/home/presentation/providers/navigation_provider.dart`     | `mainNavigationIndexProvider`                    |

### Mobile UI

| Component  | File                                                                 | Key Widgets                                  |
| ---------- | -------------------------------------------------------------------- | -------------------------------------------- |
| Home Page  | `lib/src/features/home/presentation/pages/home_page.dart`            | `_HomePageState`, `_buildDashboardContent()` |
| Navigation | `lib/src/features/home/presentation/pages/main_navigation_page.dart` | `MainNavigationPage` (ConsumerWidget)        |

---

## Common Development Tasks

### Adding a New Stat Card to Today's Overview

1. Add field to `CalorieData`/`MacroData` model
2. Update backend aggregation in `getHomeDashboardData()`
3. Add UI widget `_buildStatCard()` call
4. Update model's `fromJson()` method

Example:

```dart
// Add to CalorieData class
final int remaining;  // target - consumed

// Add to model factory
remaining: target - consumed,

// Add to UI
_buildStatCard(context, 'Remaining', '${calories.remaining}', ...)
```

### Changing Refresh Interval

Currently: Manual pull-to-refresh only

To add auto-refresh:

```dart
// In home_dashboard_provider.dart
final autoRefreshProvider = StreamProvider<HomeDashboardData>((ref) async* {
  while (true) {
    yield await ref.refresh(homeDashboardProvider.future);
    await Future.delayed(const Duration(minutes: 5));
  }
});
```

### Modifying All Meal Cards

Edit `_buildMealCard()` method in `home_page.dart`:

```dart
Widget _buildMealCard(TodayMeal meal) {
  // Modify layout, styling, data display here
}
```

### Adding Navigation to Different Tab

In `home_page.dart`:

```dart
void _navigateToTabIndex(int index) {
  ref.read(mainNavigationIndexProvider.notifier).state = index;
}
```

---

## Database Query Patterns

### Getting Today's Meals (Backend)

```javascript
// Fetch latest meal plan
const mealPlan = await MealPlan.findOne({ userId }).sort({ createdAt: -1 });

// Get today's meals (dayIndex = 0)
const meals = await MealPlanItem.find({
  mealPlanId: mealPlan._id,
  dayIndex: 0,
}).lean();
```

### Getting Upcoming Meals (Backend)

```javascript
// Get next N days
const meals = await MealPlanItem.find({
  mealPlanId: mealPlan._id,
  dayIndex: { $gte: 0, $lt: days },
})
  .sort({ dayIndex: 1 })
  .lean();

// Group by day
const grouped = meals.reduce((acc, meal) => {
  if (!acc[meal.dayIndex]) acc[meal.dayIndex] = [];
  acc[meal.dayIndex].push(meal);
  return acc;
}, {});
```

---

## Provider Usage Patterns

### Fetching Data

```dart
// In widget build
ref.watch(homeDashboardProvider).when(
  data: (dashboardData) => _buildUI(dashboardData),
  loading: () => LoadingWidget(),
  error: (error, stack) => ErrorWidget(),
)
```

### Manually Refreshing Data

```dart
// Option 1: Invalidate provider (recommended)
ref.invalidate(homeDashboardProvider);

// Option 2: Watch and refetch
try {
  await ref.watch(homeDashboardProvider.future);
} catch (e) {
  // Handle error
}
```

### Changing Navigation

```dart
ref.read(mainNavigationIndexProvider.notifier).state = 2;  // Go to Recipes tab
```

---

## Error Handling Patterns

### In Backend Service

```javascript
try {
  // Query database
  const data = await Model.findOne(...);
  return { success: true, data };
} catch (error) {
  console.error('Error:', error);
  throw new Error(`Failed to fetch: ${error.message}`);
}
```

### In API Client

```dart
try {
  final response = await _dio.get('$baseUrl/api/home/dashboard');
  if (response.statusCode == 200) {
    return HomeDashboardData.fromJson(response.data);
  }
  throw Exception('Status: ${response.statusCode}');
} catch (e) {
  throw Exception('Error fetching dashboard: $e');
}
```

### In UI

```dart
error: (error, stack) => Center(
  child: Column(
    children: [
      Text('Error: $error'),
      ElevatedButton(
        onPressed: () {
          ref.invalidate(homeDashboardProvider);
        },
        child: Text('Retry'),
      ),
    ],
  ),
)
```

---

## Testing Common Scenarios

### Empty State (No Meal Plan)

```
Database state: User has no MealPlan or latest is NULL
Expected: Shows "No meals planned yet" message
```

### Large Dataset (10+ Meals)

```
Database state: 21 meals across 3 days
Expected: Scrollable list, no performance issues
```

### Network Error

```
Setup: Intercept API call, return error
Expected: Shows error widget with retry button
```

### Authorization Error (401)

```
Setup: JWT token expired or missing
Expected: Shows "Authentication required" error
```

### Data Parsing Error

```
Setup: JSON response missing required fields
Expected: Model factory null-coalesces to defaults
```

---

## Performance Debug Tips

### Flutter DevTools

```bash
# Run with profiling
flutter run --profile

# Or attach to running app
flutter attach
```

### Check Widget Rebuild

```dart
// Add in build method
print('HomePage build called');

// Use:
// Tools > Toggle Slow Animations (Android Studio)
// Devices > Slow Animations (VS Code)
```

### Monitor Network Requests

```dart
// Use Dio interceptor
final dio = Dio();
dio.interceptors.add(
  LoggingInterceptor(),  // Log all requests
);
```

### Database Query Performance

```javascript
// Add explain() to check index usage
db.MealPlanItems.find({ mealPlanId: ObjectId(...) }).explain("executionStats")

// Result should show 'executionStages': { 'stage': 'COLLSCAN' → bad
//                                         'stage': 'FETCH' → good
```

---

## Common Regex Patterns for Search/Replace

### Finding All uses of a provider

```
Find: homeDashboardProvider
```

### Finding all meal type checks

```
Find: meal\.mealType\s*==\s*['"]
```

### Finding all navigation changes

```
Find: navigationIndexProvider.*=\s*\d
```

---

## API Integration Checklist

When connecting new endpoint:

- [ ] Define TypeScript interface for response
- [ ] Create domain model class with factory
- [ ] Add method to API client class
- [ ] Create FutureProvider wrapper
- [ ] Add error handling in try-catch
- [ ] Handle null/empty responses
- [ ] Add loading state UI
- [ ] Add error state UI
- [ ] Test with mock data first
- [ ] Test with real API
- [ ] Test error scenarios

---

## Version History

| Date       | Change                   | Files              |
| ---------- | ------------------------ | ------------------ |
| 2026-03-26 | Initial implementation   | 7 new + 2 modified |
| TBD        | Performance optimization | TBD                |
| TBD        | Add meal logging         | TBD                |
| TBD        | Add analytics            | TBD                |

---

## Support & Documentation

- **Full Implementation Details**: See `IMPLEMENTATION_COMPLETE.md`
- **Testing Guide**: See `MOBILE_HOME_TESTING.md`
- **Session Notes**: See `/memories/session/mobile_home_experience_implementation.md`

For questions or issues, refer to the troubleshooting section in `IMPLEMENTATION_COMPLETE.md`.
