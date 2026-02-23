import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/profile_api_client.dart';
import '../../domain/profile_models.dart';
import '../../../auth/data/token_storage.dart';

final dietTypesProvider = FutureProvider<List<DietTypeModel>>((ref) async {
  final api = ref.watch(profileApiClientProvider);
  return api.getDietTypes();
});

/// Helper function to decode JWT token and extract userId
Future<String?> extractUserIdFromToken() async {
  try {
    final tokenStorage = TokenStorage();
    final token = await tokenStorage.getAccessToken();
    if (token == null) return null;

    // JWT format: header.payload.signature
    final parts = token.split('.');
    if (parts.length != 3) return null;

    // Decode payload (add padding if needed)
    String payload = parts[1];
    // Add padding
    final padding = 4 - (payload.length % 4);
    if (padding != 4) {
      payload += '=' * padding;
    }

    final decoded = utf8.decode(base64.decode(payload));
    final json = jsonDecode(decoded) as Map<String, dynamic>;
    return json['sub'] as String?;
  } catch (e) {
    debugPrint('Error extracting userId from token: $e');
    return null;
  }
}

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

      // Auto-analyze health metrics after profile update
      try {
        // Extract userId from JWT token
        final userId = await extractUserIdFromToken();
        if (userId != null && state.profile is AsyncData) {
          final currentData =
              (state.profile as AsyncData<ProfileCombinedData>).value;
          final newMetrics = await _api.analyzeUserProfile(userId);
          final updatedData = ProfileCombinedData(
            profile: currentData.profile,
            dietary: currentData.dietary,
            healthMetrics: newMetrics,
          );
          state = ProfileState(
            profile: AsyncValue.data(updatedData),
            isEditing: false,
          );
        }
      } catch (e) {
        // If analyze fails, just reload profile normally
        debugPrint('Analyze failed: $e');
        await load();
      }
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
