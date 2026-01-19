import '../../domain/entities/dietary_preferences.dart';
import '../../domain/repositories/dietary_preferences_repository.dart';
import '../datasources/dietary_preferences_remote_datasource.dart';

class DietaryPreferencesRepositoryImpl implements DietaryPreferencesRepository {
  final DietaryPreferencesRemoteDataSource remoteDataSource;

  DietaryPreferencesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<DietaryPreferences> getPreferences(String userId) async {
    // TODO: Implement get preferences logic
    throw UnimplementedError();
  }

  @override
  Future<DietaryPreferences> updatePreferences(DietaryPreferences preferences) async {
    // TODO: Implement update preferences logic
    throw UnimplementedError();
  }
}
