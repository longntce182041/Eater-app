import 'package:dio/dio.dart';
import '../models/dietary_preferences_model.dart';

abstract class DietaryPreferencesRemoteDataSource {
  Future<DietaryPreferencesModel> getPreferences(String userId);
  Future<DietaryPreferencesModel> updatePreferences(DietaryPreferencesModel preferences);
}

class DietaryPreferencesRemoteDataSourceImpl implements DietaryPreferencesRemoteDataSource {
  final Dio dio;

  DietaryPreferencesRemoteDataSourceImpl(this.dio);

  @override
  Future<DietaryPreferencesModel> getPreferences(String userId) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  @override
  Future<DietaryPreferencesModel> updatePreferences(DietaryPreferencesModel preferences) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }
}
