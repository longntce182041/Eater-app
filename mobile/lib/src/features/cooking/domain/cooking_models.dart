
/// Represents a single step in a recipe cooking session
class RecipeStep {
  final int stepNumber;
  final String instruction;
  final int estimatedTime; // in seconds
  final List<StepIngredient> ingredients;
  final String tips;
  final bool completed;
  final DateTime? completedAt;
  final int? duration; // in seconds

  RecipeStep({
    required this.stepNumber,
    required this.instruction,
    required this.estimatedTime,
    required this.ingredients,
    required this.tips,
    this.completed = false,
    this.completedAt,
    this.duration,
  });

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      stepNumber: json['stepNumber'] as int,
      instruction: json['instruction'] as String,
      estimatedTime: json['estimatedTime'] as int? ?? 300,
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => StepIngredient.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      tips: json['tips'] as String? ?? '',
      completed: json['completed'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      duration: json['duration'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'stepNumber': stepNumber,
        'instruction': instruction,
        'estimatedTime': estimatedTime,
        'ingredients': ingredients.map((e) => e.toJson()).toList(),
        'tips': tips,
        'completed': completed,
        'completedAt': completedAt?.toIso8601String(),
        'duration': duration,
      };

  RecipeStep copyWith({
    int? stepNumber,
    String? instruction,
    int? estimatedTime,
    List<StepIngredient>? ingredients,
    String? tips,
    bool? completed,
    DateTime? completedAt,
    int? duration,
  }) {
    return RecipeStep(
      stepNumber: stepNumber ?? this.stepNumber,
      instruction: instruction ?? this.instruction,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      ingredients: ingredients ?? this.ingredients,
      tips: tips ?? this.tips,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      duration: duration ?? this.duration,
    );
  }
}

/// A single ingredient in a recipe step
class StepIngredient {
  final String id;
  final String name;
  final double quantity;
  final String unit;

  StepIngredient({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
  });

  factory StepIngredient.fromJson(Map<String, dynamic> json) {
    return StepIngredient(
      id: json['id'] as String? ?? '',
      name: json['name'] as String,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'quantity': quantity,
        'unit': unit,
      };

  String displayQuantity() {
    if (quantity == 0) return unit;
    if (quantity == quantity.toInt()) {
      return '${quantity.toInt()} $unit';
    }
    return '$quantity $unit';
  }
}

/// Represents an active cooking session
class CookingSession {
  final String id;
  final String recipeId;
  final int currentStepIndex;
  final List<CompletedStep> completedSteps;
  final String status; // active, paused, completed
  final DateTime startTime;
  final DateTime? pausedTime;
  final DateTime? endTime;
  final int elapsedTime; // in seconds
  final int servings;

  CookingSession({
    required this.id,
    required this.recipeId,
    required this.currentStepIndex,
    required this.completedSteps,
    required this.status,
    required this.startTime,
    this.pausedTime,
    this.endTime,
    required this.elapsedTime,
    required this.servings,
  });

  factory CookingSession.fromJson(Map<String, dynamic> json) {
    return CookingSession(
      id: json['id'] as String,
      recipeId: json['recipeId'] as String,
      currentStepIndex: json['currentStepIndex'] as int? ?? 0,
      completedSteps: (json['completedSteps'] as List<dynamic>?)
              ?.map((e) => CompletedStep.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      status: json['status'] as String? ?? 'active',
      startTime: DateTime.parse(json['startTime'] as String),
      pausedTime: json['pausedTime'] != null
          ? DateTime.parse(json['pausedTime'] as String)
          : null,
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      elapsedTime: json['elapsedTime'] as int? ?? 0,
      servings: json['servings'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'recipeId': recipeId,
        'currentStepIndex': currentStepIndex,
        'completedSteps': completedSteps.map((e) => e.toJson()).toList(),
        'status': status,
        'startTime': startTime.toIso8601String(),
        'pausedTime': pausedTime?.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'elapsedTime': elapsedTime,
        'servings': servings,
      };

  bool get isActive => status == 'active';
  bool get isPaused => status == 'paused';
  bool get isCompleted => status == 'completed';
  int get stepsCompleted => completedSteps.length;
  double get progressPercentage => 0; // Will calculate based on total steps

  CookingSession copyWith({
    String? id,
    String? recipeId,
    int? currentStepIndex,
    List<CompletedStep>? completedSteps,
    String? status,
    DateTime? startTime,
    DateTime? pausedTime,
    DateTime? endTime,
    int? elapsedTime,
    int? servings,
  }) {
    return CookingSession(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      completedSteps: completedSteps ?? this.completedSteps,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      pausedTime: pausedTime ?? this.pausedTime,
      endTime: endTime ?? this.endTime,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      servings: servings ?? this.servings,
    );
  }
}

/// Represents a completed step in a cooking session
class CompletedStep {
  final int stepNumber;
  final DateTime completedAt;
  final int? duration; // in seconds
  final String? notes;

  CompletedStep({
    required this.stepNumber,
    required this.completedAt,
    this.duration,
    this.notes,
  });

  factory CompletedStep.fromJson(Map<String, dynamic> json) {
    return CompletedStep(
      stepNumber: json['stepNumber'] as int,
      completedAt: DateTime.parse(json['completedAt'] as String),
      duration: json['duration'] as int?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'stepNumber': stepNumber,
        'completedAt': completedAt.toIso8601String(),
        'duration': duration,
        'notes': notes,
      };
}

/// Full cooking mode data (recipe + session + steps)
class CookingModeData {
  final CookingSession session;
  final RecipeBasicInfo recipe;
  final List<RecipeStep> steps;

  CookingModeData({
    required this.session,
    required this.recipe,
    required this.steps,
  });

  factory CookingModeData.fromJson(Map<String, dynamic> json) {
    return CookingModeData(
      session: CookingSession.fromJson(json['session'] as Map<String, dynamic>),
      recipe: RecipeBasicInfo.fromJson(json['recipe'] as Map<String, dynamic>),
      steps: (json['recipe']['steps'] as List<dynamic>?)
              ?.map((e) => RecipeStep.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  int get totalSteps => steps.length;
  RecipeStep get currentStep {
    if (session.currentStepIndex < steps.length) {
      return steps[session.currentStepIndex];
    }
    return steps.last;
  }

  double get progressPercentage {
    if (totalSteps == 0) return 0;
    return (session.completedSteps.length / totalSteps) * 100;
  }

  CookingModeData copyWith({
    CookingSession? session,
    RecipeBasicInfo? recipe,
    List<RecipeStep>? steps,
  }) {
    return CookingModeData(
      session: session ?? this.session,
      recipe: recipe ?? this.recipe,
      steps: steps ?? this.steps,
    );
  }
}

/// Basic recipe info for cooking mode
class RecipeBasicInfo {
  final String id;
  final String name;
  final String description;
  final int cookingTime; // in minutes
  final int baseServings;
  final String? displayImageUrl;

  RecipeBasicInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.cookingTime,
    required this.baseServings,
    this.displayImageUrl,
  });

  factory RecipeBasicInfo.fromJson(Map<String, dynamic> json) {
    return RecipeBasicInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      cookingTime: json['cookingTime'] as int? ?? 0,
      baseServings: json['baseServings'] as int? ?? 1,
      displayImageUrl: json['displayImageUrl'] as String?,
    );
  }

  String get displayCookingTime {
    if (cookingTime < 60) {
      return '$cookingTime min';
    }
    final hours = cookingTime ~/ 60;
    final minutes = cookingTime % 60;
    if (minutes == 0) {
      return '$hours h';
    }
    return '$hours h $minutes min';
  }
}
