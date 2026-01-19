import '../entities/dietary_preferences.dart';

abstract class DietaryPreferencesRepository {
  Future<DietaryPreferences> getPreferences(String userId);
  Future<DietaryPreferences> updatePreferences(DietaryPreferences preferences);
}
