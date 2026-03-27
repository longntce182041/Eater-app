import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/env/app_config.dart';
import '../../../../config/env/env_loader.dart';
import '../../../../config/router/auth_notifier.dart';
import '../../../../shared/providers/auth_token_provider.dart';
import '../../../../shared/providers/dio_provider.dart';
import '../../../grocery/presentation/providers/grocery_list_provider.dart';
import '../../../home/presentation/providers/profile_provider.dart';
import '../../../home/presentation/providers/recipe_provider.dart';
import '../../../meal_plan/presentation/providers/meal_plan_provider.dart';
import '../../data/auth_api_client.dart';
import '../../data/auth_repository.dart';
import '../../data/token_storage.dart';

final appConfigProvider = Provider<AppConfig>((ref) {
  return EnvLoader.load();
});

final authApiClientProvider = Provider<AuthApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  final config = ref.watch(appConfigProvider);
  return AuthApiClient(dio: dio, baseUrl: config.apiBaseUrl);
});

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    api: ref.watch(authApiClientProvider),
    storage: ref.watch(tokenStorageProvider),
  );
});

class AuthState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? user;

  const AuthState({this.isLoading = false, this.error, this.user});

  AuthState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    Map<String, dynamic>? user,
  }) =>
      AuthState(
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        user: user ?? this.user,
      );
}

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  final Ref _ref;

  AuthController(this._repo, this._ref) : super(const AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await _repo.login(email: email, password: password);

      // Update auth token provider with the tokens
      final accessToken = res['accessToken'] as String?;
      final refreshToken = res['refreshToken'] as String?;
      if (accessToken != null && refreshToken != null) {
        _ref.read(authTokenProvider.notifier).state =
            AuthTokenProvider.fromTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      }

      final userData = res['user'] as Map<String, dynamic>?;

      state = state.copyWith(isLoading: false, user: userData);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _errorMessage(e));
    }
  }

  Future<void> register(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await _repo.register(email: email, password: password);

      // Update auth token provider with the tokens
      final accessToken = res['accessToken'] as String?;
      final refreshToken = res['refreshToken'] as String?;

      if (accessToken != null && refreshToken != null) {
        _ref.read(authTokenProvider.notifier).state =
            AuthTokenProvider.fromTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      }

      state = state.copyWith(
        isLoading: false,
        user: res['user'] as Map<String, dynamic>?,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _errorMessage(e));
    }
  }

  Future<String> requestPasswordReset(String email) async {
    try {
      return await _repo.requestPasswordReset(email: email);
    } catch (e) {
      state = state.copyWith(error: _errorMessage(e));
      rethrow;
    }
  }

  Future<void> resetPassword(String otp, String newPassword) async {
    try {
      await _repo.resetPassword(otp: otp, newPassword: newPassword);
    } catch (e) {
      state = state.copyWith(error: _errorMessage(e));
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      // Try to logout from backend first
      await _repo.logout();
    } catch (e) {
      // Even if backend logout fails, continue with local cleanup
      debugPrint(
          '⚠️ Backend logout failed (will proceed with local cleanup): $e');
    }

    // 1. Update the GoRouter's AuthNotifier first
    // This ensures GoRouter receives the redirect trigger immediately
    _ref.read(authNotifierProvider).setAuthenticated(false);

    // 2. Invalidate all user-specific providers FIRST (mark as invalid, don't rebuild yet)
    // This ensures dependent providers will rebuild cleanly with new auth state
    try {
      _ref.invalidate(groceryListProvider);
    } catch (_) {}
    try {
      _ref.invalidate(profileNotifierProvider);
    } catch (_) {}
    try {
      _ref.invalidate(recipeListProvider);
    } catch (_) {}
    try {
      _ref.invalidate(favoriteRecipesProvider);
    } catch (_) {}
    try {
      _ref.invalidate(mealPlanNotifierProvider);
    } catch (_) {}

    // 3. Clear the auth token provider
    _ref.read(authTokenProvider.notifier).state = const AuthTokenProvider(
      accessToken: null,
      refreshToken: null,
      userId: null,
    );

    // 4. Clear auth state
    // When dependent providers that watch authControllerProvider rebuild,
    // they will see the cleared auth state after invalidation
    state = const AuthState();
  }

  String _errorMessage(Object e) {
    if (e is DioException) {
      return e.response?.data is Map && e.response?.data['message'] != null
          ? e.response!.data['message'].toString()
          : (e.message ?? 'Network error');
    }
    return e.toString();
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(ref.watch(authRepositoryProvider), ref);
  },
);
