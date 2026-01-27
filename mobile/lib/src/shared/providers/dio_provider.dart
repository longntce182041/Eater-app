import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  // Add interceptor for authentication
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        debugPrint('Making request to: ${options.path}');
        debugPrint(
          'Auth token state - accessToken: ${authToken.accessToken != null ? "present (${authToken.accessToken!.length} chars)" : "null"}, refreshToken: ${authToken.refreshToken != null ? "present" : "null"}',
        );

        if (authToken.accessToken != null) {
          options.headers['Authorization'] = 'Bearer ${authToken.accessToken}';
          debugPrint('Added Authorization header to request');
        } else {
          debugPrint(
            'No access token available - request will be unauthenticated',
          );
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        debugPrint(
          'Request error to ${error.requestOptions.path}: ${error.response?.statusCode} - ${error.message}',
        );
        if (error.response?.statusCode == 401) {
          debugPrint('Got 401 Unauthorized - token may be invalid or missing');
        }
        return handler.next(error);
      },
    ),
  );

  return dio;
});
