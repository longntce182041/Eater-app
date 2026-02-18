class AuthUserModel {
  final String id;
  final String email;
  final String role;

  const AuthUserModel({
    required this.id,
    required this.email,
    required this.role,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      role: (json['role'] ?? 'user').toString(),
    );
  }
}
