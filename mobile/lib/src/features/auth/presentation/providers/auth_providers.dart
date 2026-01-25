import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/env/app_config.dart';
import '../../../../config/env/env_loader.dart';
import '../../data/auth_api_client.dart';
import '../../data/auth_repository.dart';
import '../../data/token_storage.dart';

final appConfigProvider = Provider<AppConfig>((ref) {
  return EnvLoader.load();
});

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  dio.options.headers['Content-Type'] = 'application/json';
  return dio;
});

final authApiClientProvider = Provider<AuthApiClient>((ref) {
  final config = ref.watch(appConfigProvider);
  final dio = ref.watch(dioProvider);
  return AuthApiClient(dio: dio, baseUrl: '${config.apiBaseUrl}/api');
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
    Map<String, dynamic>? user,
  }) => AuthState(
    isLoading: isLoading ?? this.isLoading,
    error: error,
    user: user ?? this.user,
  );
}

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  AuthController(this._repo) : super(const AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _repo.login(email: email, password: password);
      state = state.copyWith(
        isLoading: false,
        user: res['user'] as Map<String, dynamic>?,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _errorMessage(e));
    }
  }

  Future<void> register(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _repo.register(email: email, password: password);
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
    await _repo.logout();
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
    return AuthController(ref.watch(authRepositoryProvider));
  },
);
