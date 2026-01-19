import '../models/health_info_model.dart';
import '../models/user_profile_model.dart';

/// Local data source for caching user profile data.
abstract class UserProfileLocalDataSource {
  /// Caches the user's profile.
  Future<void> cacheUserProfile(UserProfileModel profile);

  /// Gets the cached user profile.
  Future<UserProfileModel?> getCachedUserProfile();

  /// Caches the user's health information.
  Future<void> cacheHealthInfo(HealthInfoModel healthInfo);

  /// Gets the cached health information.
  Future<HealthInfoModel?> getCachedHealthInfo();

  /// Clears all cached profile data.
  Future<void> clearCache();
}
