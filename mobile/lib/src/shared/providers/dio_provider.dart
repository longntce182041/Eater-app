import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/router/auth_notifier.dart';
import '../../core/network/interceptors/auth_interceptor.dart';
import '../../features/auth/data/auth_session_manager.dart';
import '../../features/auth/data/token_storage.dart';
import '../../shared/services/jwt_service.dart';
import 'app_config_provider.dart';
import 'auth_token_provider.dart';

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final jwtService = JwtService();
  final storage = TokenStorage();

  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  final sessionManager = AuthSessionManager(
    storage: storage,
    jwtService: jwtService,
    baseUrl: config.apiBaseUrl,
  );

  /// Clears all stored tokens and redirects to the sign-in screen.
  Future<void> hardLogout() async {
    ref.read(authTokenProvider.notifier).state = const AuthTokenProvider(
      accessToken: null,
      refreshToken: null,
      userId: null,
    );
    try {
      await sessionManager.clearSession();
      ref.read(authNotifierProvider).setAuthenticated(false);
    } catch (_) {}
  }

  dio.interceptors.add(
    AuthInterceptor(
      dio: dio,
      sessionManager: sessionManager,
      onSessionExpired: () async {
        await hardLogout();
      },
      onTokensRefreshed: (accessToken, refreshToken) async {
        ref.read(authTokenProvider.notifier).state =
            AuthTokenProvider.fromTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      },
    ),
  );

  return dio;
});
