import '../../domain/entities/health_info.dart';

class HealthInfoModel {
  final String id;
  final String userId;
  final String activityLevel;
  final List<String> healthConditions;
  final List<String> allergies;
  final String? medicalNotes;
  final double? targetWeight;
  final String? fitnessGoal;

  HealthInfoModel({
    required this.id,
    required this.userId,
    required this.activityLevel,
    required this.healthConditions,
    required this.allergies,
    this.medicalNotes,
    this.targetWeight,
    this.fitnessGoal,
  });

  factory HealthInfoModel.fromJson(Map<String, dynamic> json) {
    return HealthInfoModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      activityLevel: json['activity_level'] as String,
      healthConditions: (json['health_conditions'] as List).cast<String>(),
      allergies: (json['allergies'] as List).cast<String>(),
      medicalNotes: json['medical_notes'] as String?,
      targetWeight: json['target_weight'] != null ? (json['target_weight'] as num).toDouble() : null,
      fitnessGoal: json['fitness_goal'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'activity_level': activityLevel,
      'health_conditions': healthConditions,
      'allergies': allergies,
      'medical_notes': medicalNotes,
      'target_weight': targetWeight,
      'fitness_goal': fitnessGoal,
    };
  }

  HealthInfo toEntity() {
    return HealthInfo(
      id: id,
      userId: userId,
      activityLevel: activityLevel,
      healthConditions: healthConditions,
      allergies: allergies,
      medicalNotes: medicalNotes,
      targetWeight: targetWeight,
      fitnessGoal: fitnessGoal,
    );
  }
}
