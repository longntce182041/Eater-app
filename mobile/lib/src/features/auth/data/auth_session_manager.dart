import 'dart:async';

import 'package:dio/dio.dart';

import '../../../shared/services/jwt_service.dart';
import 'token_storage.dart';

enum RefreshFailureReason {
  none,
  missingRefreshToken,
  expiredRefreshToken,
  refreshRejected,
  network,
  unknown,
}

class RefreshResult {
  final bool isSuccess;
  final RefreshFailureReason failureReason;

  const RefreshResult._({
    required this.isSuccess,
    required this.failureReason,
  });

  const RefreshResult.success()
      : this._(isSuccess: true, failureReason: RefreshFailureReason.none);

  const RefreshResult.failure(RefreshFailureReason reason)
      : this._(isSuccess: false, failureReason: reason);
}

class AuthSessionManager {
  static const _refreshPath = '/api/auth/user/refresh';

  final TokenStorage _storage;
  final JwtService _jwtService;
  final Dio _refreshDio;
  final Duration _refreshLeeway;

  String? _accessToken;
  String? _refreshToken;
  bool _isInitialized = false;
  Completer<RefreshResult>? _refreshCompleter;

  AuthSessionManager({
    required TokenStorage storage,
    required JwtService jwtService,
    required String baseUrl,
    Duration refreshLeeway = const Duration(seconds: 30),
  })  : _storage = storage,
        _jwtService = jwtService,
        _refreshLeeway = refreshLeeway,
        _refreshDio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    await _reloadFromStorage();
    _isInitialized = true;
  }

  Future<void> _reloadFromStorage() async {
    _accessToken = await _storage.getAccessToken();
    _refreshToken = await _storage.getRefreshToken();
  }

  Future<String?> getAccessToken() async {
    await _ensureInitialized();
    if (_accessToken == null || _accessToken!.isEmpty) {
      await _reloadFromStorage();
    }
    return _accessToken;
  }

  Future<String?> getRefreshToken() async {
    await _ensureInitialized();
    if (_refreshToken == null || _refreshToken!.isEmpty) {
      await _reloadFromStorage();
    }
    return _refreshToken;
  }

  Future<void> setTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _isInitialized = true;
  }

  Future<bool> hasRefreshToken() async {
    final rt = await getRefreshToken();
    return rt != null && rt.isNotEmpty;
  }

  Future<bool> isRefreshTokenExpired() async {
    final rt = await getRefreshToken();
    if (rt == null || rt.isEmpty) return true;
    return _jwtService.isExpired(rt);
  }

  Future<bool> shouldProactivelyRefresh() async {
    final at = await getAccessToken();
    if (at == null || at.isEmpty) {
      return false;
    }
    return _jwtService.willExpireWithin(at, _refreshLeeway);
  }

  Future<RefreshResult> refreshTokens() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<RefreshResult>();

    try {
      await _ensureInitialized();
      final rt = _refreshToken;

      if (rt == null || rt.isEmpty) {
        _refreshCompleter!.complete(
          const RefreshResult.failure(RefreshFailureReason.missingRefreshToken),
        );
        return _refreshCompleter!.future;
      }

      if (_jwtService.isExpired(rt)) {
        _refreshCompleter!.complete(
          const RefreshResult.failure(RefreshFailureReason.expiredRefreshToken),
        );
        return _refreshCompleter!.future;
      }

      final res = await _refreshDio.post(
        _refreshPath,
        data: {'refreshToken': rt},
      );

      final payload = (res.data is Map<String, dynamic>)
          ? (res.data['data'] ?? res.data)
          : null;

      if (payload is! Map) {
        _refreshCompleter!.complete(
          const RefreshResult.failure(RefreshFailureReason.unknown),
        );
        return _refreshCompleter!.future;
      }

      final newAccessToken = payload['accessToken'] as String?;
      final refreshedToken = payload['refreshToken'] as String?;

      if (newAccessToken == null || newAccessToken.isEmpty) {
        _refreshCompleter!.complete(
          const RefreshResult.failure(RefreshFailureReason.unknown),
        );
        return _refreshCompleter!.future;
      }

      await setTokens(
        accessToken: newAccessToken,
        refreshToken: (refreshedToken == null || refreshedToken.isEmpty)
            ? rt
            : refreshedToken,
      );

      _refreshCompleter!.complete(const RefreshResult.success());
      return _refreshCompleter!.future;
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        _refreshCompleter!.complete(
          const RefreshResult.failure(RefreshFailureReason.refreshRejected),
        );
      } else {
        _refreshCompleter!.complete(
          const RefreshResult.failure(RefreshFailureReason.network),
        );
      }
      return _refreshCompleter!.future;
    } catch (_) {
      _refreshCompleter!.complete(
        const RefreshResult.failure(RefreshFailureReason.unknown),
      );
      return _refreshCompleter!.future;
    } finally {
      _refreshCompleter = null;
    }
  }

  Future<void> clearSession() async {
    await _storage.clear();
    _accessToken = null;
    _refreshToken = null;
    _isInitialized = true;
  }
}
