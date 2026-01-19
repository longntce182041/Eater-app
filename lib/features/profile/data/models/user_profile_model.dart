import '../../domain/entities/user_profile.dart';

class UserProfileModel {
  final String id;
  final String userId;
  final String name;
  final int age;
  final String gender;
  final double height;
  final double weight;
  final String? avatarUrl;

  UserProfileModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    this.avatarUrl,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      gender: json['gender'] as String,
      height: (json['height'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'avatar_url': avatarUrl,
    };
  }

  UserProfile toEntity() {
    return UserProfile(
      id: id,
      userId: userId,
      name: name,
      age: age,
      gender: gender,
      height: height,
      weight: weight,
      avatarUrl: avatarUrl,
    );
  }
}
