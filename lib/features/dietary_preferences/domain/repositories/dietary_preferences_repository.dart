import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/dietary_preferences.dart';
import '../entities/health_goal.dart';

/// Repository interface for dietary preferences operations.
abstract class DietaryPreferencesRepository {
  /// Gets the user's dietary preferences.
  Future<Either<Failure, DietaryPreferences>> getDietaryPreferences();

  /// Updates the user's dietary preferences.
  Future<Either<Failure, DietaryPreferences>> updateDietaryPreferences(
    DietaryPreferences preferences,
  );

  /// Gets the user's health goals.
  Future<Either<Failure, List<HealthGoal>>> getHealthGoals();

  /// Creates a new health goal.
  Future<Either<Failure, HealthGoal>> createHealthGoal(HealthGoal goal);

  /// Updates a health goal.
  Future<Either<Failure, HealthGoal>> updateHealthGoal(HealthGoal goal);

  /// Deletes a health goal.
  Future<Either<Failure, void>> deleteHealthGoal(String goalId);

  /// Gets available diet types.
  Future<Either<Failure, List<String>>> getAvailableDietTypes();

  /// Gets common allergens.
  Future<Either<Failure, List<String>>> getCommonAllergens();
}
