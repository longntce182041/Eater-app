import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/auth_tokens.dart';
import '../entities/user.dart';

/// Repository interface for authentication operations.
abstract class AuthRepository {
  /// Authenticates user with email and password.
  Future<Either<Failure, (User, AuthTokens)>> login({
    required String email,
    required String password,
  });

  /// Registers a new user.
  Future<Either<Failure, (User, AuthTokens)>> register({
    required String email,
    required String password,
    required String confirmPassword,
    String? username,
  });

  /// Logs out the current user.
  Future<Either<Failure, void>> logout();

  /// Sends a password reset email.
  Future<Either<Failure, void>> forgotPassword({
    required String email,
  });

  /// Resets password with token.
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  });

  /// Refreshes the access token.
  Future<Either<Failure, AuthTokens>> refreshToken();

  /// Gets the currently authenticated user.
  Future<Either<Failure, User?>> getCurrentUser();

  /// Checks if user is authenticated.
  Future<bool> isAuthenticated();
}
