import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<UserProfile> call(UserProfile profile) {
    return repository.updateProfile(profile);
  }
}
