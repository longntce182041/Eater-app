abstract class Failure {
  final String message;
  final Object? cause;

  const Failure(this.message, {this.cause});
}

class ServerFailure extends Failure {
  const ServerFailure(String message, {Object? cause}) : super(message, cause: cause);
}

class CacheFailure extends Failure {
  const CacheFailure(String message, {Object? cause}) : super(message, cause: cause);
}

class AuthFailure extends Failure {
  const AuthFailure(String message, {Object? cause}) : super(message, cause: cause);
}