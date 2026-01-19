import 'package:equatable/equatable.dart';

/// Health goals entity.
class HealthGoal extends Equatable {
  final String id;
  final String userId;
  final String goalType; // e.g., weight_loss, muscle_gain, maintenance
  final double? targetWeight;
  final DateTime? targetDate;
  final int? dailyCalorieTarget;
  final String? notes;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const HealthGoal({
    required this.id,
    required this.userId,
    required this.goalType,
    this.targetWeight,
    this.targetDate,
    this.dailyCalorieTarget,
    this.notes,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        goalType,
        targetWeight,
        targetDate,
        dailyCalorieTarget,
        notes,
        isActive,
        createdAt,
        updatedAt,
      ];
}
