import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/router/auth_notifier.dart';
import '../../features/auth/data/token_storage.dart';
import 'app_config_provider.dart';
import 'auth_token_provider.dart';

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final authToken = ref.watch(authTokenProvider);

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

  // Auth token injection + 401 auto-logout
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        if (authToken.accessToken != null) {
          options.headers['Authorization'] = 'Bearer ${authToken.accessToken}';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token expired — clear state and force re-login
          ref.read(authTokenProvider.notifier).state = const AuthTokenProvider(
            accessToken: null,
            refreshToken: null,
            userId: null,
          );
          try {
            await TokenStorage().clear();
            ref.read(authNotifierProvider).setAuthenticated(false);
          } catch (_) {}
        }
        return handler.next(error);
      },
    ),
  );

  return dio;
});
