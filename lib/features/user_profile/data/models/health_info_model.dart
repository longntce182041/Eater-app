import '../../domain/entities/health_info.dart';

/// Data model for HealthInfo.
class HealthInfoModel extends HealthInfo {
  const HealthInfoModel({
    required super.userId,
    super.dailyCalorieGoal,
    super.dailyProteinGoal,
    super.dailyCarbsGoal,
    super.dailyFatGoal,
    super.dailyFiberGoal,
    super.medicalConditions = const [],
    super.medications = const [],
    super.updatedAt,
  });

  /// Creates a HealthInfoModel from JSON.
  factory HealthInfoModel.fromJson(Map<String, dynamic> json) {
    return HealthInfoModel(
      userId: json['user_id'] as String,
      dailyCalorieGoal: json['daily_calorie_goal'] as int?,
      dailyProteinGoal: json['daily_protein_goal'] as int?,
      dailyCarbsGoal: json['daily_carbs_goal'] as int?,
      dailyFatGoal: json['daily_fat_goal'] as int?,
      dailyFiberGoal: json['daily_fiber_goal'] as int?,
      medicalConditions: (json['medical_conditions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      medications: (json['medications'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Converts the model to JSON.
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'daily_calorie_goal': dailyCalorieGoal,
      'daily_protein_goal': dailyProteinGoal,
      'daily_carbs_goal': dailyCarbsGoal,
      'daily_fat_goal': dailyFatGoal,
      'daily_fiber_goal': dailyFiberGoal,
      'medical_conditions': medicalConditions,
      'medications': medications,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
