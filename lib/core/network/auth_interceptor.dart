import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/api_constants.dart';
import '../errors/exceptions.dart';

/// Interceptor that handles JWT authentication.
/// Adds access token to requests and handles token refresh.
class AuthInterceptor extends Interceptor {
  final Ref _ref;

  AuthInterceptor(this._ref);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // TODO: Get access token from secure storage
    // final accessToken = await _ref.read(secureStorageProvider).getAccessToken();
    // if (accessToken != null) {
    //   options.headers['Authorization'] = 'Bearer $accessToken';
    // }

    handler.next(options);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Token expired, attempt to refresh
      try {
        await _refreshToken();
        
        // Retry the original request
        final response = await _retry(err.requestOptions);
        handler.resolve(response);
        return;
      } on TokenExpiredException {
        // Refresh failed, logout user
        // TODO: Trigger logout
        // _ref.read(authProvider.notifier).logout();
      }
    }

    handler.next(err);
  }

  /// Attempts to refresh the access token.
  Future<void> _refreshToken() async {
    // TODO: Implement token refresh logic
    // final refreshToken = await _ref.read(secureStorageProvider).getRefreshToken();
    // if (refreshToken == null) {
    //   throw const TokenExpiredException();
    // }
    //
    // final response = await Dio().post(
    //   '${ApiConstants.baseUrl}${ApiConstants.refreshToken}',
    //   data: {'refresh_token': refreshToken},
    // );
    //
    // final newAccessToken = response.data['access_token'];
    // final newRefreshToken = response.data['refresh_token'];
    //
    // await _ref.read(secureStorageProvider).saveTokens(
    //   accessToken: newAccessToken,
    //   refreshToken: newRefreshToken,
    // );
    throw const TokenExpiredException();
  }

  /// Retries the failed request with new access token.
  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    // TODO: Get new access token and retry
    // final accessToken = await _ref.read(secureStorageProvider).getAccessToken();
    
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        // 'Authorization': 'Bearer $accessToken',
      },
    );

    return Dio().request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}
