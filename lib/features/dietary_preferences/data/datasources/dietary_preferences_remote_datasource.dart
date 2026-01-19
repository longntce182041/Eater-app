import '../models/dietary_preferences_model.dart';
import '../models/health_goal_model.dart';

/// Remote data source for dietary preferences operations.
abstract class DietaryPreferencesRemoteDataSource {
  /// Gets the user's dietary preferences.
  Future<DietaryPreferencesModel> getDietaryPreferences();

  /// Updates the user's dietary preferences.
  Future<DietaryPreferencesModel> updateDietaryPreferences(
    DietaryPreferencesModel preferences,
  );

  /// Gets the user's health goals.
  Future<List<HealthGoalModel>> getHealthGoals();

  /// Creates a new health goal.
  Future<HealthGoalModel> createHealthGoal(HealthGoalModel goal);

  /// Updates a health goal.
  Future<HealthGoalModel> updateHealthGoal(HealthGoalModel goal);

  /// Deletes a health goal.
  Future<void> deleteHealthGoal(String goalId);

  /// Gets available diet types.
  Future<List<String>> getAvailableDietTypes();

  /// Gets common allergens.
  Future<List<String>> getCommonAllergens();
}
