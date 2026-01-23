class AuthUser {
  final String id;
  final String email;
  final String passwordHash;
  final String role;



  const AuthUser({
    required this.id,
    required this.email,
    required this.passwordHash,
    required this.role,
  });
}