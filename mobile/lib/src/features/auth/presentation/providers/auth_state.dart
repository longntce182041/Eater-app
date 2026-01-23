class AuthState {
  final bool isLoading;
  final String? errorMessage;
  // Add more fields such as currentUser if needed.

  const AuthState({
    required this.isLoading,
    this.errorMessage,
  });

  const AuthState.initial()
      : isLoading = false,
        errorMessage = null;

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}