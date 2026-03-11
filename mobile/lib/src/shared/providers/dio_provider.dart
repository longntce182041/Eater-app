import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/router/auth_notifier.dart';
import '../../features/auth/data/token_storage.dart';
import 'app_config_provider.dart';
import 'auth_token_provider.dart';

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);

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

  // Lock to prevent concurrent refresh calls
  bool isRefreshing = false;

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        // Read current token on every request (not captured at provider init)
        final currentToken = ref.read(authTokenProvider);
        if (currentToken.accessToken != null) {
          options.headers['Authorization'] =
              'Bearer ${currentToken.accessToken}';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        final is401 = error.response?.statusCode == 401;
        final isRetry = error.requestOptions.extra['_isRetry'] == true;

        if (is401 && !isRetry && !isRefreshing) {
          final storage = TokenStorage();
          final rt = await storage.getRefreshToken();

          if (rt != null && rt.isNotEmpty) {
            isRefreshing = true;
            try {
              // Plain Dio — no interceptors — to avoid an infinite loop
              final plainDio = Dio(
                BaseOptions(
                  connectTimeout: const Duration(seconds: 15),
                  receiveTimeout: const Duration(seconds: 15),
                ),
              );
              final res = await plainDio.post(
                '${config.apiBaseUrl}/api/auth/user/refresh',
                data: {'refreshToken': rt},
              );
              final data = res.data['data'] ?? res.data;
              final newAt = data['accessToken'] as String?;
              final newRt = data['refreshToken'] as String?;

              if (newAt != null && newRt != null) {
                await storage.saveTokens(
                    accessToken: newAt, refreshToken: newRt);
                ref.read(authTokenProvider.notifier).state =
                    AuthTokenProvider.fromTokens(
                  accessToken: newAt,
                  refreshToken: newRt,
                );
                // Retry original request — onRequest will inject the new token
                error.requestOptions.extra['_isRetry'] = true;
                final retryResponse = await dio.fetch(error.requestOptions);
                isRefreshing = false;
                return handler.resolve(retryResponse);
              }
            } catch (_) {
              // Refresh failed — fall through to hard logout
            }
            isRefreshing = false;
          }

          // Hard logout: clear tokens and redirect to sign-in
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
