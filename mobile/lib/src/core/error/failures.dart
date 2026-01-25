abstract class Failure {
  final String message;
  final Object? cause;

  const Failure(this.message, {this.cause});
}

class ServerFailure extends Failure {
  const ServerFailure({required String message, Object? cause})
    : super(message, cause: cause);
}

class CacheFailure extends Failure {
  const CacheFailure({required String message, Object? cause})
    : super(message, cause: cause);
}

class AuthFailure extends Failure {
  const AuthFailure({required String message, Object? cause})
    : super(message, cause: cause);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({required String message, Object? cause})
    : super(message, cause: cause);
}
