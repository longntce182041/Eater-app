import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user.dart';

/// State for authentication.
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Auth state class.
class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Auth notifier for managing authentication state.
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  /// Logs in the user.
  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);

    // TODO: Implement login logic using LoginUseCase
    // final result = await _loginUseCase(LoginParams(email: email, password: password));
    // result.fold(
    //   (failure) => state = state.copyWith(
    //     status: AuthStatus.error,
    //     errorMessage: failure.message,
    //   ),
    //   (data) => state = state.copyWith(
    //     status: AuthStatus.authenticated,
    //     user: data.$1,
    //   ),
    // );
  }

  /// Registers a new user.
  Future<void> register(String email, String password, String confirmPassword) async {
    state = state.copyWith(status: AuthStatus.loading);

    // TODO: Implement register logic using RegisterUseCase
  }

  /// Logs out the user.
  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);

    // TODO: Implement logout logic using LogoutUseCase
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Sends forgot password email.
  Future<void> forgotPassword(String email) async {
    // TODO: Implement forgot password logic using ForgotPasswordUseCase
  }

  /// Resets the password.
  Future<void> resetPassword(String token, String newPassword, String confirmPassword) async {
    // TODO: Implement reset password logic using ResetPasswordUseCase
  }
}

/// Provider for auth state.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
