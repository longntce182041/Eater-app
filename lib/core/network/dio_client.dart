import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import 'auth_interceptor.dart';
import 'logging_interceptor.dart';

/// Provider for the Dio HTTP client.
final dioProvider = Provider<Dio>((ref) {
  return DioClient.createDio(ref);
});

/// Configures and creates the Dio HTTP client instance.
class DioClient {
  DioClient._();

  /// Creates and configures a Dio instance with interceptors.
  static Dio createDio(Ref ref) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: AppConstants.connectionTimeout),
        receiveTimeout: const Duration(seconds: AppConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    dio.interceptors.addAll([
      AuthInterceptor(ref),
      LoggingInterceptor(),
    ]);

    return dio;
  }
}
