// Health Information Entity
class HealthInfo {
  final String id;
  final String userId;
  final String activityLevel; // sedentary, light, moderate, active, very_active
  final List<String> healthConditions;
  final List<String> allergies;
  final String? medicalNotes;
  final double? targetWeight;
  final String? fitnessGoal; // lose_weight, maintain, gain_muscle

  HealthInfo({
    required this.id,
    required this.userId,
    required this.activityLevel,
    required this.healthConditions,
    required this.allergies,
    this.medicalNotes,
    this.targetWeight,
    this.fitnessGoal,
  });
}
