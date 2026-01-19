import 'package:equatable/equatable.dart';

/// User entity representing authenticated user data.
class User extends Equatable {
  final String id;
  final String email;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.email,
    this.username,
    this.firstName,
    this.lastName,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
  });

  /// Returns the user's display name.
  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return username ?? email;
  }

  @override
  List<Object?> get props => [
        id,
        email,
        username,
        firstName,
        lastName,
        avatarUrl,
        createdAt,
        updatedAt,
      ];
}
