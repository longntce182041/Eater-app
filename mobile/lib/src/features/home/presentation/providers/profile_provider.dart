import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/profile_api_client.dart';
import '../../domain/profile_models.dart';

class ProfileState {
  final AsyncValue<ProfileCombinedData> profile;
  final bool isEditing;

  ProfileState({required this.profile, this.isEditing = false});

  ProfileState copyWith({
    AsyncValue<ProfileCombinedData>? profile,
    bool? isEditing,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isEditing: isEditing ?? this.isEditing,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileApiClient _api;
  ProfileNotifier(this._api)
    : super(ProfileState(profile: const AsyncValue.loading())) {
    load();
  }

  Future<void> load() async {
    try {
      final data = await _api.getProfile();
      state = state.copyWith(profile: AsyncValue.data(data));
    } catch (e, st) {
      state = state.copyWith(profile: AsyncValue.error(e, st));
    }
  }

  void toggleEdit([bool? value]) {
    state = state.copyWith(isEditing: value ?? !state.isEditing);
  }

  Future<void> saveUpdates({required Map<String, dynamic> updates}) async {
    state = state.copyWith(profile: const AsyncValue.loading());
    try {
      final updated = await _api.updateProfile(updates);
      state = ProfileState(profile: AsyncValue.data(updated), isEditing: false);
    } catch (e, st) {
      state = state.copyWith(profile: AsyncValue.error(e, st));
    }
  }
}

final profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
      final api = ref.watch(profileApiClientProvider);
      return ProfileNotifier(api);
    });
