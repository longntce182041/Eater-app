enum ConsultationStatus { pending, accepted, answered, closed }

enum ConsultationCategory { diet, weight, healthGoal, mealPlan, other }

extension ConsultationStatusX on ConsultationStatus {
  String get value {
    switch (this) {
      case ConsultationStatus.pending:
        return 'pending';
      case ConsultationStatus.accepted:
        return 'accepted';
      case ConsultationStatus.answered:
        return 'answered';
      case ConsultationStatus.closed:
        return 'closed';
    }
  }

  String get label {
    switch (this) {
      case ConsultationStatus.pending:
        return 'Pending';
      case ConsultationStatus.accepted:
        return 'Accepted';
      case ConsultationStatus.answered:
        return 'Answered';
      case ConsultationStatus.closed:
        return 'Closed';
    }
  }

  static ConsultationStatus fromString(String? value) {
    switch (value) {
      case 'accepted':
        return ConsultationStatus.accepted;
      case 'answered':
        return ConsultationStatus.answered;
      case 'closed':
        return ConsultationStatus.closed;
      default:
        return ConsultationStatus.pending;
    }
  }
}

extension ConsultationCategoryX on ConsultationCategory {
  String get value {
    switch (this) {
      case ConsultationCategory.diet:
        return 'diet';
      case ConsultationCategory.weight:
        return 'weight';
      case ConsultationCategory.healthGoal:
        return 'health_goal';
      case ConsultationCategory.mealPlan:
        return 'meal_plan';
      case ConsultationCategory.other:
        return 'other';
    }
  }

  String get label {
    switch (this) {
      case ConsultationCategory.diet:
        return 'Diet';
      case ConsultationCategory.weight:
        return 'Weight';
      case ConsultationCategory.healthGoal:
        return 'Health Goal';
      case ConsultationCategory.mealPlan:
        return 'Meal Plan';
      case ConsultationCategory.other:
        return 'Other';
    }
  }

  static ConsultationCategory fromString(String? value) {
    switch (value) {
      case 'weight':
        return ConsultationCategory.weight;
      case 'health_goal':
        return ConsultationCategory.healthGoal;
      case 'meal_plan':
        return ConsultationCategory.mealPlan;
      case 'other':
        return ConsultationCategory.other;
      default:
        return ConsultationCategory.diet;
    }
  }
}

class NutritionistInfo {
  final String id;
  final String fullName;
  final String specialization;
  final int experience;
  final String? email;

  const NutritionistInfo({
    required this.id,
    required this.fullName,
    required this.specialization,
    required this.experience,
    this.email,
  });

  factory NutritionistInfo.fromJson(Map<String, dynamic> json) {
    return NutritionistInfo(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName'] as String? ?? '',
      specialization: json['specialization'] as String? ?? '',
      experience: (json['experience'] as num?)?.toInt() ?? 0,
      email: json['email'] as String?,
    );
  }
}

class ConsultationSummary {
  final String id;
  final String title;
  final String message;
  final ConsultationCategory category;
  final ConsultationStatus status;
  final NutritionistInfo? nutritionist;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ConsultationSummary({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
    required this.status,
    this.nutritionist,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ConsultationSummary.fromJson(Map<String, dynamic> json) {
    final nutriJson = json['nutritionist'] as Map<String, dynamic>?;
    return ConsultationSummary(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      category: ConsultationCategoryX.fromString(json['category'] as String?),
      status: ConsultationStatusX.fromString(json['status'] as String?),
      nutritionist:
          nutriJson != null ? NutritionistInfo.fromJson(nutriJson) : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }
}

class ConsultationReply {
  final String id;
  final String senderEmail;
  final String senderRole;
  final String content;
  final DateTime createdAt;

  const ConsultationReply({
    required this.id,
    required this.senderEmail,
    required this.senderRole,
    required this.content,
    required this.createdAt,
  });

  factory ConsultationReply.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'] as Map<String, dynamic>?;
    return ConsultationReply(
      id: json['id']?.toString() ?? '',
      senderEmail: sender?['email'] as String? ?? 'Unknown',
      senderRole: json['senderRole'] as String? ?? 'user',
      content: json['content'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}

class ConsultationDetail extends ConsultationSummary {
  final List<ConsultationReply> replies;

  const ConsultationDetail({
    required super.id,
    required super.title,
    required super.message,
    required super.category,
    required super.status,
    super.nutritionist,
    required super.createdAt,
    required super.updatedAt,
    required this.replies,
  });

  factory ConsultationDetail.fromJson(Map<String, dynamic> json) {
    final base = ConsultationSummary.fromJson(json);
    final repliesJson = json['replies'] as List<dynamic>? ?? [];
    return ConsultationDetail(
      id: base.id,
      title: base.title,
      message: base.message,
      category: base.category,
      status: base.status,
      nutritionist: base.nutritionist,
      createdAt: base.createdAt,
      updatedAt: base.updatedAt,
      replies: repliesJson
          .map((r) => ConsultationReply.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CreateConsultationDto {
  final String title;
  final String message;
  final ConsultationCategory category;
  final String? nutritionistId;

  const CreateConsultationDto({
    required this.title,
    required this.message,
    required this.category,
    this.nutritionistId,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'message': message,
        'category': category.value,
        if (nutritionistId != null) 'nutritionistId': nutritionistId,
      };
}
