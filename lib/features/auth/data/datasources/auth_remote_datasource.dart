import '../models/auth_tokens_model.dart';
import '../models/user_model.dart';

/// Remote data source for authentication operations.
abstract class AuthRemoteDataSource {
  /// Authenticates user with email and password.
  Future<(UserModel, AuthTokensModel)> login({
    required String email,
    required String password,
  });

  /// Registers a new user.
  Future<(UserModel, AuthTokensModel)> register({
    required String email,
    required String password,
    required String confirmPassword,
    String? username,
  });

  /// Logs out the current user.
  Future<void> logout();

  /// Sends a password reset email.
  Future<void> forgotPassword({required String email});

  /// Resets password with token.
  Future<void> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  });

  /// Refreshes the access token.
  Future<AuthTokensModel> refreshToken(String refreshToken);

  /// Gets the current user's profile.
  Future<UserModel> getCurrentUser();
}
