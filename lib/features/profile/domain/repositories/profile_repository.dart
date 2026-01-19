import '../entities/user_profile.dart';
import '../entities/health_info.dart';

abstract class ProfileRepository {
  Future<UserProfile> getProfile(String userId);
  Future<UserProfile> updateProfile(UserProfile profile);
  Future<HealthInfo> getHealthInfo(String userId);
  Future<HealthInfo> updateHealthInfo(HealthInfo healthInfo);
}
