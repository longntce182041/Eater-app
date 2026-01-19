import '../../domain/entities/health_goal.dart';

/// Data model for HealthGoal.
class HealthGoalModel extends HealthGoal {
  const HealthGoalModel({
    required super.id,
    required super.userId,
    required super.goalType,
    super.targetWeight,
    super.targetDate,
    super.dailyCalorieTarget,
    super.notes,
    super.isActive = true,
    super.createdAt,
    super.updatedAt,
  });

  /// Creates a HealthGoalModel from JSON.
  factory HealthGoalModel.fromJson(Map<String, dynamic> json) {
    return HealthGoalModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      goalType: json['goal_type'] as String,
      targetWeight: (json['target_weight'] as num?)?.toDouble(),
      targetDate: json['target_date'] != null
          ? DateTime.parse(json['target_date'] as String)
          : null,
      dailyCalorieTarget: json['daily_calorie_target'] as int?,
      notes: json['notes'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Converts the model to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'goal_type': goalType,
      'target_weight': targetWeight,
      'target_date': targetDate?.toIso8601String(),
      'daily_calorie_target': dailyCalorieTarget,
      'notes': notes,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
