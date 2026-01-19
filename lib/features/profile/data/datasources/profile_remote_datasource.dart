import 'package:dio/dio.dart';
import '../models/user_profile_model.dart';
import '../models/health_info_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getProfile(String userId);
  Future<UserProfileModel> updateProfile(UserProfileModel profile);
  Future<HealthInfoModel> getHealthInfo(String userId);
  Future<HealthInfoModel> updateHealthInfo(HealthInfoModel healthInfo);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;

  ProfileRemoteDataSourceImpl(this.dio);

  @override
  Future<UserProfileModel> getProfile(String userId) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  @override
  Future<UserProfileModel> updateProfile(UserProfileModel profile) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  @override
  Future<HealthInfoModel> getHealthInfo(String userId) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  @override
  Future<HealthInfoModel> updateHealthInfo(HealthInfoModel healthInfo) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }
}
