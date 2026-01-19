import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user_profile.dart';

/// State for user profile.
enum UserProfileStatus {
  initial,
  loading,
  loaded,
  error,
}

/// User profile state class.
class UserProfileState {
  final UserProfileStatus status;
  final UserProfile? profile;
  final String? errorMessage;

  const UserProfileState({
    this.status = UserProfileStatus.initial,
    this.profile,
    this.errorMessage,
  });

  UserProfileState copyWith({
    UserProfileStatus? status,
    UserProfile? profile,
    String? errorMessage,
  }) {
    return UserProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// User profile notifier for managing profile state.
class UserProfileNotifier extends StateNotifier<UserProfileState> {
  UserProfileNotifier() : super(const UserProfileState());

  /// Loads the user profile.
  Future<void> loadProfile() async {
    state = state.copyWith(status: UserProfileStatus.loading);

    // TODO: Implement using GetUserProfileUseCase
  }

  /// Updates the user profile.
  Future<void> updateProfile(UserProfile profile) async {
    state = state.copyWith(status: UserProfileStatus.loading);

    // TODO: Implement using UpdateUserProfileUseCase
  }
}

/// Provider for user profile state.
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfileState>((ref) {
  return UserProfileNotifier();
});
