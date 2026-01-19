import '../entities/dietary_preferences.dart';
import '../repositories/dietary_preferences_repository.dart';

class GetDietaryPreferencesUseCase {
  final DietaryPreferencesRepository repository;

  GetDietaryPreferencesUseCase(this.repository);

  Future<DietaryPreferences> call(String userId) {
    return repository.getPreferences(userId);
  }
}
