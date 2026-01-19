import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/user_profile.dart';
import '../repositories/user_profile_repository.dart';

/// Use case for updating user profile.
class UpdateUserProfileUseCase implements UseCase<UserProfile, UserProfile> {
  final UserProfileRepository repository;

  UpdateUserProfileUseCase(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(UserProfile params) {
    return repository.updateUserProfile(params);
  }
}
