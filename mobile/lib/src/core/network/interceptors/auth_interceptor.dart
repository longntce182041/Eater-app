import 'package:dio/dio.dart';

import '../../../shared/providers/auth_token_provider.dart';

class AuthInterceptor extends Interceptor {
  final AuthTokenProvider authTokenProvider;

  AuthInterceptor(this.authTokenProvider);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = authTokenProvider.accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }
}