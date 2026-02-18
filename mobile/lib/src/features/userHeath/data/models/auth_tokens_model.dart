class AuthTokensModel {
  final String accessToken;
  final String refreshToken;

  const AuthTokensModel({
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    // Backend returns keys 'accessToken' and 'refreshToken'.
    return AuthTokensModel(
      accessToken: (json['accessToken'] ?? json['access_token']).toString(),
      refreshToken: (json['refreshToken'] ?? json['refresh_token']).toString(),
    );
  }
}
