import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/health_info.dart';
import '../entities/user_profile.dart';

/// Repository interface for user profile operations.
abstract class UserProfileRepository {
  /// Gets the user's profile.
  Future<Either<Failure, UserProfile>> getUserProfile();

  /// Updates the user's profile.
  Future<Either<Failure, UserProfile>> updateUserProfile(UserProfile profile);

  /// Gets the user's health information.
  Future<Either<Failure, HealthInfo>> getHealthInfo();

  /// Updates the user's health information.
  Future<Either<Failure, HealthInfo>> updateHealthInfo(HealthInfo healthInfo);

  /// Uploads a profile avatar.
  Future<Either<Failure, String>> uploadAvatar(String filePath);

  /// Deletes the user's account.
  Future<Either<Failure, void>> deleteAccount();
}
