import '../models/dietary_preferences_model.dart';
import '../models/health_goal_model.dart';

/// Local data source for caching dietary preferences data.
abstract class DietaryPreferencesLocalDataSource {
  /// Caches dietary preferences.
  Future<void> cacheDietaryPreferences(DietaryPreferencesModel preferences);

  /// Gets cached dietary preferences.
  Future<DietaryPreferencesModel?> getCachedDietaryPreferences();

  /// Caches health goals.
  Future<void> cacheHealthGoals(List<HealthGoalModel> goals);

  /// Gets cached health goals.
  Future<List<HealthGoalModel>?> getCachedHealthGoals();

  /// Clears all cached data.
  Future<void> clearCache();
}
