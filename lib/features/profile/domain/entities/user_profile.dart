// User Profile Entity
class UserProfile {
  final String id;
  final String userId;
  final String name;
  final int age;
  final String gender;
  final double height; // in cm
  final double weight; // in kg
  final String? avatarUrl;

  UserProfile({
    required this.id,
    required this.userId,
    required this.name,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    this.avatarUrl,
  });
}
