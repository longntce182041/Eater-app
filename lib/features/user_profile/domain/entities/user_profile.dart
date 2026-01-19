import 'package:equatable/equatable.dart';

/// User profile entity with health information.
class UserProfile extends Equatable {
  final String userId;
  final String? firstName;
  final String? lastName;
  final String? avatarUrl;
  final DateTime? dateOfBirth;
  final String? gender;
  final double? height; // in cm
  final double? weight; // in kg
  final String? activityLevel;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.userId,
    this.firstName,
    this.lastName,
    this.avatarUrl,
    this.dateOfBirth,
    this.gender,
    this.height,
    this.weight,
    this.activityLevel,
    this.createdAt,
    this.updatedAt,
  });

  /// Calculates BMI if height and weight are available.
  double? get bmi {
    if (height == null || weight == null || height == 0) return null;
    final heightInMeters = height! / 100;
    return weight! / (heightInMeters * heightInMeters);
  }

  /// Returns the age in years.
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  @override
  List<Object?> get props => [
        userId,
        firstName,
        lastName,
        avatarUrl,
        dateOfBirth,
        gender,
        height,
        weight,
        activityLevel,
        createdAt,
        updatedAt,
      ];
}
