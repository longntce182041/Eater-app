import '../../domain/entities/user_profile.dart';
import '../../domain/entities/health_info.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserProfile> getProfile(String userId) async {
    // TODO: Implement get profile logic
    throw UnimplementedError();
  }

  @override
  Future<UserProfile> updateProfile(UserProfile profile) async {
    // TODO: Implement update profile logic
    throw UnimplementedError();
  }

  @override
  Future<HealthInfo> getHealthInfo(String userId) async {
    // TODO: Implement get health info logic
    throw UnimplementedError();
  }

  @override
  Future<HealthInfo> updateHealthInfo(HealthInfo healthInfo) async {
    // TODO: Implement update health info logic
    throw UnimplementedError();
  }
}
