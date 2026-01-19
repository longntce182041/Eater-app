import 'package:equatable/equatable.dart';

/// Health information entity.
class HealthInfo extends Equatable {
  final String userId;
  final int? dailyCalorieGoal;
  final int? dailyProteinGoal;
  final int? dailyCarbsGoal;
  final int? dailyFatGoal;
  final int? dailyFiberGoal;
  final List<String> medicalConditions;
  final List<String> medications;
  final DateTime? updatedAt;

  const HealthInfo({
    required this.userId,
    this.dailyCalorieGoal,
    this.dailyProteinGoal,
    this.dailyCarbsGoal,
    this.dailyFatGoal,
    this.dailyFiberGoal,
    this.medicalConditions = const [],
    this.medications = const [],
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        userId,
        dailyCalorieGoal,
        dailyProteinGoal,
        dailyCarbsGoal,
        dailyFatGoal,
        dailyFiberGoal,
        medicalConditions,
        medications,
        updatedAt,
      ];
}
