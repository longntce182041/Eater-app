import 'package:dio/dio.dart';

import '../../../features/auth/data/auth_session_manager.dart';

class AuthInterceptor extends Interceptor {
  static const _retryFlag = '_auth_retry_attempted';
  static const _skipAuthFlag = '_skip_auth';

  final Dio _dio;
  final AuthSessionManager _sessionManager;
  final Future<void> Function() _onSessionExpired;
  final Future<void> Function(String accessToken, String refreshToken)?
      _onTokensRefreshed;

  AuthInterceptor({
    required Dio dio,
    required AuthSessionManager sessionManager,
    required Future<void> Function() onSessionExpired,
    Future<void> Function(String accessToken, String refreshToken)?
        onTokensRefreshed,
  })  : _dio = dio,
        _sessionManager = sessionManager,
        _onSessionExpired = onSessionExpired,
        _onTokensRefreshed = onTokensRefreshed;

  bool _isSkippableAuthRequest(RequestOptions options) {
    if (options.extra[_skipAuthFlag] == true) {
      return true;
    }
    final path = options.path;
    return path.contains('/api/auth/user/login') ||
        path.contains('/api/auth/user/register') ||
        path.contains('/api/auth/user/refresh') ||
        path.contains('/api/auth/user/request-password-reset') ||
        path.contains('/api/auth/user/reset-password');
  }

  bool _shouldForceLogout(RefreshFailureReason reason) {
    return reason == RefreshFailureReason.missingRefreshToken ||
        reason == RefreshFailureReason.expiredRefreshToken ||
        reason == RefreshFailureReason.refreshRejected;
  }

  Future<void> _syncRefreshedTokens() async {
    if (_onTokensRefreshed == null) return;
    final accessToken = await _sessionManager.getAccessToken();
    final refreshToken = await _sessionManager.getRefreshToken();
    if (accessToken == null || accessToken.isEmpty) return;
    if (refreshToken == null || refreshToken.isEmpty) return;
    await _onTokensRefreshed(accessToken, refreshToken);
  }

  Future<Response<dynamic>> _retryWithLatestAccessToken(
    RequestOptions requestOptions,
  ) async {
    final latestToken = await _sessionManager.getAccessToken();
    if (latestToken != null && latestToken.isNotEmpty) {
      requestOptions.headers['Authorization'] = 'Bearer $latestToken';
    }
    requestOptions.extra[_retryFlag] = true;
    return _dio.fetch(requestOptions);
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_isSkippableAuthRequest(options)) {
      return handler.next(options);
    }

    final accessToken = await _sessionManager.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      return handler.next(options);
    }

    if (await _sessionManager.shouldProactivelyRefresh()) {
      final refreshResult = await _sessionManager.refreshTokens();
      if (!refreshResult.isSuccess &&
          _shouldForceLogout(refreshResult.failureReason)) {
        await _onSessionExpired();
        return handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.cancel,
            message: 'Session expired. Please log in again.',
          ),
        );
      }
      if (refreshResult.isSuccess) {
        await _syncRefreshedTokens();
      }
    }

    final latestAccessToken = await _sessionManager.getAccessToken();
    if (latestAccessToken != null && latestAccessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $latestAccessToken';
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final requestOptions = err.requestOptions;
    final isRetried = requestOptions.extra[_retryFlag] == true;

    if (_isSkippableAuthRequest(requestOptions) ||
        err.response?.statusCode != 401 ||
        isRetried) {
      return handler.next(err);
    }

    final refreshResult = await _sessionManager.refreshTokens();
    if (refreshResult.isSuccess) {
      await _syncRefreshedTokens();
      try {
        final retryResponse = await _retryWithLatestAccessToken(requestOptions);
        return handler.resolve(retryResponse);
      } on DioException catch (retryError) {
        return handler.next(retryError);
      } catch (_) {
        return handler.next(err);
      }
    }

    if (_shouldForceLogout(refreshResult.failureReason)) {
      await _onSessionExpired();
    }

    return handler.next(err);
  }
}
