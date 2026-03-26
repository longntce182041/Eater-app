import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/router/auth_notifier.dart';
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

  // A single Completer<bool> that is non-null while a refresh is in progress.
  // All concurrent callers await the same future so only one HTTP call is made.
  Completer<bool>? _refreshCompleter;

  /// Refreshes tokens.  Returns true on success, false on failure.
  /// Concurrent callers share the same in-flight refresh via [_refreshCompleter].
  Future<bool> _refreshTokens() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<bool>();
    try {
      final rt = await storage.getRefreshToken();
      if (rt == null || rt.isEmpty) {
        _refreshCompleter!.complete(false);
        _refreshCompleter = null;
        return false;
      }

      // Use a plain Dio instance without interceptors to avoid infinite loops.
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
        await storage.saveTokens(accessToken: newAt, refreshToken: newRt);
        ref.read(authTokenProvider.notifier).state =
            AuthTokenProvider.fromTokens(
          accessToken: newAt,
          refreshToken: newRt,
        );
        _refreshCompleter!.complete(true);
        _refreshCompleter = null;
        return true;
      }
    } catch (e, st) {
      // Log the error to aid debugging refresh failures in development.
      debugPrint('🔒 Token refresh failed: $e\n$st');
    }

    _refreshCompleter!.complete(false);
    _refreshCompleter = null;
    return false;
  }

  /// Clears all stored tokens and redirects to the sign-in screen.
  Future<void> _hardLogout() async {
    ref.read(authTokenProvider.notifier).state = const AuthTokenProvider(
      accessToken: null,
      refreshToken: null,
      userId: null,
    );
    try {
      await storage.clear();
      ref.read(authNotifierProvider).setAuthenticated(false);
    } catch (_) {}
  }

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final currentToken = ref.read(authTokenProvider);
        final at = currentToken.accessToken;

        if (at != null && at.isNotEmpty) {
          // Proactively refresh when the stored access token is already expired.
          if (jwtService.isExpired(at)) {
            final success = await _refreshTokens();
            if (!success) {
              await _hardLogout();
              return handler.reject(
                DioException(
                  requestOptions: options,
                  type: DioExceptionType.cancel,
                  message: 'Session expired. Please log in again.',
                ),
              );
            }
          }

          // Attach the latest (possibly refreshed) token.
          final latestToken = ref.read(authTokenProvider);
          if (latestToken.accessToken != null) {
            options.headers['Authorization'] =
                'Bearer ${latestToken.accessToken}';
          }
        }

        return handler.next(options);
      },
      onError: (error, handler) async {
        final is401 = error.response?.statusCode == 401;
        final isRetry = error.requestOptions.extra['_isRetry'] == true;

        if (is401 && !isRetry) {
          // Attempt to refresh (concurrent callers share the same refresh).
          final success = await _refreshTokens();

          if (success) {
            // Retry the original request with the new token.
            error.requestOptions.extra['_isRetry'] = true;
            try {
              final retryResponse = await dio.fetch(error.requestOptions);
              return handler.resolve(retryResponse);
            } catch (_) {
              // Retry itself failed — fall through to hard logout.
            }
          }

          await _hardLogout();
        }

        return handler.next(error);
      },
    ),
  );

  return dio;
});

