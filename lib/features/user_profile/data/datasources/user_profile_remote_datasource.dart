import '../models/health_info_model.dart';
import '../models/user_profile_model.dart';

/// Remote data source for user profile operations.
abstract class UserProfileRemoteDataSource {
  /// Gets the user's profile.
  Future<UserProfileModel> getUserProfile();

  /// Updates the user's profile.
  Future<UserProfileModel> updateUserProfile(UserProfileModel profile);

  /// Gets the user's health information.
  Future<HealthInfoModel> getHealthInfo();

  /// Updates the user's health information.
  Future<HealthInfoModel> updateHealthInfo(HealthInfoModel healthInfo);

  /// Uploads a profile avatar.
  Future<String> uploadAvatar(String filePath);

  /// Deletes the user's account.
  Future<void> deleteAccount();
}
