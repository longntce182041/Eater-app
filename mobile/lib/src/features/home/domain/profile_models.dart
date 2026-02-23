class UserProfileModel {
  final String id;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final int age;
  final String gender;
  final double height;
  final double weight;
  final double? goalWeight;
  final String? healthGoals;

  UserProfileModel({
    required this.id,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    this.goalWeight,
    this.healthGoals,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['_id'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      age: json['age'] != null ? (json['age'] as num).toInt() : 0,
      gender: json['gender'] as String? ?? 'other',
      height: json['height'] != null ? (json['height'] as num).toDouble() : 0.0,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : 0.0,
      goalWeight: json['goal_weight'] != null
          ? (json['goal_weight'] as num).toDouble()
          : null,
      healthGoals: json['healthGoals'] as String?,
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      if (goalWeight != null) 'goal_weight': goalWeight,
      if (healthGoals != null) 'healthGoals': healthGoals,
    };
  }
}

class DietTypeModel {
  final String id;
  final String name;
  final String? description;
  final double? carbRatio;
  final double? proteinRatio;
  final double? fatRatio;

  DietTypeModel({
    required this.id,
    required this.name,
    this.description,
    this.carbRatio,
    this.proteinRatio,
    this.fatRatio,
  });

  factory DietTypeModel.fromJson(Map<String, dynamic> json) {
    return DietTypeModel(
      id: (json['_id']?.toString() ?? json['Diet_TypeId']?.toString() ?? ''),
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      carbRatio: (json['carb_ratio'] as num?)?.toDouble(),
      proteinRatio: (json['protein_ratio'] as num?)?.toDouble(),
      fatRatio: (json['fat_ratio'] as num?)?.toDouble(),
    );
  }
}

class DietTypeRef {
  final String id;
  final String? name;

  DietTypeRef({required this.id, this.name});

  factory DietTypeRef.fromJson(dynamic json) {
    if (json is String) {
      return DietTypeRef(id: json);
    }
    final map = json as Map<String, dynamic>;
    return DietTypeRef(id: map['_id'] as String, name: map['name'] as String?);
  }
}

class DietaryReferencesModel {
  final String id;
  final String userId;
  final DietTypeRef? dietType;
  final List<String> allergies;
  final List<String> dislikesIngredients;
  final String activityLevel;
  final String cookingSkillLevel;
  final int availableCookingTime;
  final int dailyCalorieTarget;

  DietaryReferencesModel({
    required this.id,
    required this.userId,
    this.dietType,
    required this.allergies,
    required this.dislikesIngredients,
    required this.activityLevel,
    required this.cookingSkillLevel,
    required this.availableCookingTime,
    required this.dailyCalorieTarget,
  });

  factory DietaryReferencesModel.fromJson(Map<String, dynamic> json) {
    return DietaryReferencesModel(
      id: json['_id'] as String,
      userId: json['userId'] is Map<String, dynamic>
          ? (json['userId'] as Map<String, dynamic>)['_id'] as String
          : json['userId'] as String,
      dietType: json['diet_typeId'] != null
          ? DietTypeRef.fromJson(json['diet_typeId'])
          : null,
      allergies: (json['allergies'] as List<dynamic>? ?? []).cast<String>(),
      dislikesIngredients: (json['dislikesIngredients'] as List<dynamic>? ?? [])
          .cast<String>(),
      activityLevel: json['activityLevel'] as String? ?? 'sedentary',
      cookingSkillLevel: json['cookingSkillLevel'] as String? ?? 'beginner',
      availableCookingTime: json['available_cooking_time'] != null
          ? (json['available_cooking_time'] as num).toInt()
          : 30,
      dailyCalorieTarget: json['daily_calorie_target'] != null
          ? (json['daily_calorie_target'] as num).toInt()
          : 2000,
    );
  }

  Map<String, dynamic> toUpdateJson({String? dietTypeId}) {
    return {
      if (dietTypeId != null) 'diet_typeId': dietTypeId,
      'allergies': allergies,
      'dislikesIngredients': dislikesIngredients,
      'activityLevel': activityLevel,
      'cookingSkillLevel': cookingSkillLevel,
      'available_cooking_time': availableCookingTime,
      'daily_calorie_target': dailyCalorieTarget,
    };
  }
}

class HealthMetricsModel {
  final String id;
  final double bmi;
  final double bmr;
  final double tdee;
  final String bodyCategory;
  final String source; // 'AI' or 'Nutritionist'
  final DateTime calculatedAt;

  HealthMetricsModel({
    required this.id,
    required this.bmi,
    required this.bmr,
    required this.tdee,
    required this.bodyCategory,
    required this.source,
    required this.calculatedAt,
  });

  factory HealthMetricsModel.fromJson(Map<String, dynamic> json) {
    return HealthMetricsModel(
      id: json['_id'] as String? ?? '',
      bmi: (json['bmi'] as num?)?.toDouble() ?? 0.0,
      bmr: (json['bmr'] as num?)?.toDouble() ?? 0.0,
      tdee: (json['tdee'] as num?)?.toDouble() ?? 0.0,
      bodyCategory: json['body_category'] as String? ?? '',
      source: json['source'] as String? ?? 'AI',
      calculatedAt: json['calculatedAt'] != null
          ? DateTime.parse(json['calculatedAt'] as String)
          : DateTime.now(),
    );
  }
}

class ProfileCombinedData {
  final UserProfileModel profile;
  final DietaryReferencesModel? dietary;
  final HealthMetricsModel? healthMetrics;

  ProfileCombinedData({
    required this.profile,
    required this.dietary,
    this.healthMetrics,
  });

  factory ProfileCombinedData.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final profile = UserProfileModel.fromJson(
      data['profile'] as Map<String, dynamic>,
    );
    final dietaryRaw = data['dietaryReferences'];
    final dietary = dietaryRaw != null
        ? DietaryReferencesModel.fromJson(dietaryRaw as Map<String, dynamic>)
        : null;
    final healthMetricsRaw = data['healthMetrics'];
    final healthMetrics = healthMetricsRaw != null
        ? HealthMetricsModel.fromJson(healthMetricsRaw as Map<String, dynamic>)
        : null;
    return ProfileCombinedData(
      profile: profile,
      dietary: dietary,
      healthMetrics: healthMetrics,
    );
  }
}
