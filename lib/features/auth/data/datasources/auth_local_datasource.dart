import '../models/auth_tokens_model.dart';
import '../models/user_model.dart';

/// Local data source for authentication data caching.
abstract class AuthLocalDataSource {
  /// Saves authentication tokens.
  Future<void> saveTokens(AuthTokensModel tokens);

  /// Gets cached authentication tokens.
  Future<AuthTokensModel?> getTokens();

  /// Clears cached authentication tokens.
  Future<void> clearTokens();

  /// Saves current user data.
  Future<void> saveUser(UserModel user);

  /// Gets cached user data.
  Future<UserModel?> getUser();

  /// Clears cached user data.
  Future<void> clearUser();

  /// Clears all authentication related data.
  Future<void> clearAll();
}
