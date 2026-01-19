/// Base class for all exceptions in the application.
class AppException implements Exception {
  final String message;
  final int? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Exception thrown when server returns an error.
class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Exception thrown when cache operation fails.
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Exception thrown when there's no network connectivity.
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection',
    super.code,
    super.originalError,
  });
}

/// Exception thrown when authentication fails.
class AuthenticationException extends AppException {
  const AuthenticationException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Exception thrown when token is expired.
class TokenExpiredException extends AuthenticationException {
  const TokenExpiredException({
    super.message = 'Session expired. Please login again.',
    super.code,
    super.originalError,
  });
}

/// Exception thrown when token refresh fails.
class RefreshTokenException extends AuthenticationException {
  const RefreshTokenException({
    super.message = 'Unable to refresh session. Please login again.',
    super.code,
    super.originalError,
  });
}

/// Exception thrown when validation fails.
class ValidationException extends AppException {
  final Map<String, List<String>>? fieldErrors;

  const ValidationException({
    required super.message,
    super.code,
    super.originalError,
    this.fieldErrors,
  });
}

/// Exception thrown when a resource is not found.
class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'Resource not found',
    super.code,
    super.originalError,
  });
}
