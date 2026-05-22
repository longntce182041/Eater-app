/// 👨‍🍳 INTERACTIVE COOKING DATA MODELS
///
/// This file contains all domain models for the interactive cooking feature:
/// - RecipeStep: Individual cooking instruction with ingredients and timing
/// - StepIngredient: Ingredient needed for a specific step
/// - CookingSession: Active cooking session tracking and state
/// - CompletedStep: Historical record of completed steps
/// - CookingModeData: Complete cooking session data (session + recipe + steps)
/// - RecipeBasicInfo: Recipe metadata for cooking mode
///
/// Data Flow:
/// 1. User taps "Start Cooking" on recipe
/// 2. Backend initializes CookingSession with recipe ID
/// 3. RecipeSteps loaded with ingredients and timing
/// 4. UI displays current RecipeStep from CookingModeData
/// 5. User completes step → CookingSession.currentStepIndex increments
/// 6. CompletedStep recorded for analytics/history
///
/// All models implement:
/// - fromJson() → Parse API JSON response to Dart object
/// - toJson() → Serialize to JSON for API requests
/// - copyWith() → Create modified copy (immutability pattern)
/// - Null-safety with sensible defaults
library;

/// 📍 Cooking Recipe Step
///
/// Represents a single instruction in the cooking process with:
/// - stepNumber: Order in the recipe (1-based indexing)
/// - instruction: Detailed text describing what to do
/// - estimatedTime: How long this step typically takes (in seconds)
/// - ingredients: List of ingredients needed for this step
/// - tips: Pro tips and helpful hints for this step
/// - completed: Whether user has marked this step as done
/// - completedAt: When the step was completed (for analytics)
/// - duration: How long the user actually took (in seconds)
///
/// Example:
/// ```
/// stepNumber: 1
/// instruction: "Preheat oven to 350°F"
/// estimatedTime: 300 (5 minutes)
/// ingredients: [flour 2 cups, sugar 1 cup]
/// tips: "Use a reliable oven thermometer for accuracy"
/// completed: false
/// ```
///
/// Usage in UI:
/// - Display in large, readable format during cooking
/// - Ingredients shown below instruction
/// - Timer based on estimatedTime
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

  /// 📥 Parse JSON response from backend into RecipeStep
  ///
  /// Handles:
  /// - Safe type casting (num? → int)
  /// - Default values for optional fields
  /// - Nested ingredients list parsing
  /// - DateTime parsing for timestamps
  ///
  /// Example JSON:
  /// ```json
  /// {
  ///   "stepNumber": 1,
  ///   "instruction": "Preheat oven to 350°F",
  ///   "estimatedTime": 300,
  ///   "ingredients": [
  ///     {"id": "flour_1", "name": "Flour", "quantity": 2, "unit": "cups"},
  ///     {"id": "sugar_1", "name": "Sugar", "quantity": 1, "unit": "cup"}
  ///   ],
  ///   "tips": "Use oven thermometer for accuracy",
  ///   "completed": false,
  ///   "completedAt": "2024-03-29T10:15:00Z"
  /// }
  /// ```
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

  /// 📤 Convert RecipeStep to JSON for API requests
  ///
  /// Serializes all fields including timestamps
  /// Used when sending step completion to server
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

  /// 📋 Create a modified copy of this step while keeping other fields unchanged
  ///
  /// Used to update step state (e.g., mark as completed):
  /// ```dart
  /// final updatedStep = step.copyWith(
  ///   completed: true,
  ///   completedAt: DateTime.now(),
  ///   duration: actualSeconds
  /// );
  /// ```
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

/// 🥘 Ingredient for a Cooking Step
///
/// Represents a single ingredient needed for a specific step:
/// - id: Unique ingredient identifier (for nutrition tracking)
/// - name: User-friendly name ("Flour", "Salt", etc.)
/// - quantity: Amount needed (2.5, 1, 0.5, etc.)
/// - unit: Measurement unit ("cups", "tsp", "g", "ml", etc.)
///
/// Note: Quantity is per serving - automatically scaled by backend
/// based on CookingSession.servings
///
/// Display:
/// - Shows as "2 1/2 cups flour" or "1 cup sugar"
/// - Uses displayQuantity() for user-friendly formatting
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

  /// 📥 Parse JSON response into StepIngredient
  ///
  /// Example JSON:
  /// ```json
  /// {
  ///   "id": "flour_all_purpose_1",
  ///   "name": "All-Purpose Flour",
  ///   "quantity": 2.5,
  ///   "unit": "cups"
  /// }
  /// ```
  factory StepIngredient.fromJson(Map<String, dynamic> json) {
    return StepIngredient(
      id: json['id'] as String? ?? '',
      name: json['name'] as String,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? '',
    );
  }

  /// 📤 Convert to JSON for API requests
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'quantity': quantity,
        'unit': unit,
      };

  /// 🎨 Display ingredient quantity in user-friendly format
  ///
  /// Handles edge cases:
  /// - 0 quantity: Just show unit (e.g., "salt")
  /// - Whole numbers: "2 cups" (not "2.0 cups")
  /// - Decimals: "2.5 cups" or "0.5 tsp"
  ///
  /// Examples:
  /// - displayQuantity() on "2.5 cups flour" → "2.5 cups"
  /// - displayQuantity() on "1 egg" → "1"
  /// - displayQuantity() on "0.5 tsp salt" → "0.5 tsp"
  String displayQuantity() {
    if (quantity == 0) return unit;
    if (quantity == quantity.toInt()) {
      return '${quantity.toInt()} $unit';
    }
    return '$quantity $unit';
  }
}

/// 📍 Active Cooking Session
///
/// Represents the user's ongoing cooking session with tracking:
/// - id: Unique session identifier (for API queries)
/// - recipeId: Which recipe is being cooked
/// - currentStepIndex: Which step user is on (0-based)
/// - completedSteps: List of steps already finished (for progress)
/// - status: Session state ("active", "paused", "completed")
/// - startTime: When cooking began
/// - pausedTime: When user paused (if applicable)
/// - endTime: When cooking finished (if completed)
/// - elapsedTime: Total time spent (in seconds)
/// - servings: How many servings user is making (affects quantities)
///
/// Status Flow:
/// ```
/// active → (user pauses) → paused → (user resumes) → active → (user finishes) → completed
/// ```
///
/// Example:
/// ```
/// id: "session_abc123"
/// recipeId: "recipe_pancakes_1"
/// currentStepIndex: 2 (on step 3 of 5)
/// completedSteps: [step 1, step 2]
/// status: "active"
/// servings: 4 (making 4 servings instead of base 2)
/// ```
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

  /// 📥 Parse backend JSON response into CookingSession
  ///
  /// Handles DateTime parsing and safe type casting
  ///
  /// Example JSON response from GET /api/recipes/:id/cook/session/:sessionId:
  /// ```json
  /// {
  ///   "id": "session_xyz",
  ///   "recipeId": "recipe_123",
  ///   "currentStepIndex": 2,
  ///   "completedSteps": [
  ///     {"stepNumber": 1, "completedAt": "2024-03-29T10:15:00Z", "duration": 300},
  ///     {"stepNumber": 2, "completedAt": "2024-03-29T10:20:00Z", "duration": 420}
  ///   ],
  ///   "status": "active",
  ///   "startTime": "2024-03-29T10:00:00Z",
  ///   "elapsedTime": 900,
  ///   "servings": 4
  /// }
  /// ```
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

  /// 📤 Serialize CookingSession to JSON for API requests
  ///
  /// Converts timestamps to ISO8601 format
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

  /// 🔍 Helper getters for session state checking
  bool get isActive => status == 'active';
  bool get isPaused => status == 'paused';
  bool get isCompleted => status == 'completed';

  /// Get count of completed steps so far
  int get stepsCompleted => completedSteps.length;

  /// Calculate progress percentage (0-100)
  /// Used to show progress bar: completedSteps / totalSteps * 100
  double get progressPercentage => 0; // Will calculate based on total steps

  /// 📋 Create modified copy of session
  ///
  /// Used to advance step or change status:
  /// ```dart
  /// final nextSession = session.copyWith(
  ///   currentStepIndex: session.currentStepIndex + 1,
  ///   status: 'active'
  /// );
  /// ```
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

/// 📝 Record of a Completed Cooking Step
///
/// Tracks when a step was finished and how long it took:
/// - stepNumber: Which step (1-based)
/// - completedAt: Timestamp when user marked it done
/// - duration: How long the user spent on this step (in seconds)
/// - notes: Optional user notes about the step
///
/// Used for:
/// - Building history of cooking session
/// - Analytics (how long each step takes)
/// - User feedback and improvement
///
/// Example:
/// ```
/// stepNumber: 2
/// completedAt: 2024-03-29T10:20:00Z
/// duration: 420 (7 minutes)
/// notes: "Needed extra time for mixing"
/// ```
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

  /// 📥 Parse completed step from JSON
  factory CompletedStep.fromJson(Map<String, dynamic> json) {
    return CompletedStep(
      stepNumber: json['stepNumber'] as int,
      completedAt: DateTime.parse(json['completedAt'] as String),
      duration: json['duration'] as int?,
      notes: json['notes'] as String?,
    );
  }

  /// 📤 Serialize to JSON for API
  Map<String, dynamic> toJson() => {
        'stepNumber': stepNumber,
        'completedAt': completedAt.toIso8601String(),
        'duration': duration,
        'notes': notes,
      };
}

/// 🍳 Complete Cooking Mode Data
///
/// Container holding all data needed for cooking mode UI:
/// - session: The active cooking session (tracks progress, timing)
/// - recipe: Recipe metadata (name, image, cooking time)
/// - steps: List of all cooking instructions (for this session's servings)
///
/// This is the complete package sent by the backend when starting a cooking session.
/// Includes everything needed to display and track the cooking experience.
///
/// Data Structure:
/// ```
/// CookingModeData
///   ├─ session: CookingSession (abc123)
///   │  ├─ currentStepIndex: 0
///   │  ├─ status: "active"
///   │  ├─ startTime: 2024-03-29T10:00:00Z
///   │  └─ servings: 4
///   ├─ recipe: RecipeBasicInfo
///   │  ├─ name: "Pancakes"
///   │  ├─ cookingTime: 20 (minutes)
///   │  └─ baseServings: 2
///   └─ steps: List<RecipeStep> [5 steps]
///      ├─ Step 1: "Mix dry ingredients"
///      ├─ Step 2: "Mix wet ingredients"
///      └─ ...
/// ```
///
/// Calculated Properties:
/// - totalSteps: Count of all steps
/// - currentStep: The RecipeStep user is currently on (auto-indexed)
/// - progressPercentage: How much is done (0-100%)
class CookingModeData {
  final CookingSession session;
  final RecipeBasicInfo recipe;
  final List<RecipeStep> steps;

  CookingModeData({
    required this.session,
    required this.recipe,
    required this.steps,
  });

  /// 📥 Parse complete cooking mode data from backend
  ///
  /// Backend endpoint response: POST /api/recipes/:id/cook/start
  /// Includes session info + recipe details + all steps for this session
  ///
  /// Note: Steps are nested under recipe.steps in the JSON response
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

  /// 📊 Total number of steps in the recipe
  int get totalSteps => steps.length;

  /// 🎯 Get the current step user should be working on
  ///
  /// Returns the RecipeStep at currentStepIndex
  /// Safely handles edge case where index >= steps.length (returns last step)
  ///
  /// Example:
  /// - Session on step 0 → returns steps[0]
  /// - Session on step 4 (of 5) → returns steps[4]
  /// - Session on step 5 (out of bounds) → returns steps[4] (last)
  RecipeStep get currentStep {
    if (session.currentStepIndex < steps.length) {
      return steps[session.currentStepIndex];
    }
    return steps.last;
  }

  /// 📈 Calculate progress percentage (0-100)
  ///
  /// Based on completedSteps / totalSteps
  /// Used for progress bar:
  /// - 0/5 steps = 0%
  /// - 2/5 steps = 40%
  /// - 5/5 steps = 100%
  double get progressPercentage {
    if (totalSteps == 0) return 0;
    return (session.completedSteps.length / totalSteps) * 100;
  }

  /// 📋 Create modified copy while preserving other fields
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

/// 📘 Recipe Basic Information for Cooking Mode
///
/// Minimal recipe info needed during cooking:
/// - id: Recipe identifier (for API calls)
/// - name: Display name ("Pancakes", "Grilled Salmon")
/// - description: Short description shown at top
/// - cookingTime: Total estimated time (in minutes, not seconds!)
/// - baseServings: Default serving size (user might cook for different amount)
/// - displayImageUrl: Recipe hero image shown at top (if available)
///
/// Note: Ingredients are NOT included here (they're in RecipeStep.ingredients per step)
///
/// Example:
/// ```
/// id: "recipe_123"
/// name: "Fluffy Pancakes"
/// description: "Classic breakfast pancakes"
/// cookingTime: 20 (minutes total, not seconds)
/// baseServings: 2
/// displayImageUrl: "https://cdn.example.com/pancakes.jpg"
/// ```
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

  /// 📥 Parse recipe info from backend JSON
  ///
  /// Example JSON:
  /// ```json
  /// {
  ///   "id": "recipe_pancakes_1",
  ///   "name": "Fluffy Pancakes",
  ///   "description": "Classic breakfast pancakes",
  ///   "cookingTime": 20,
  ///   "baseServings": 2,
  ///   "displayImageUrl": "https://cdn.example.com/pancakes.jpg"
  /// }
  /// ```
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

  /// ⏱️ Format cooking time into human-readable string
  ///
  /// Converts minutes to smart display format:
  /// - < 60 min: "45 min" or "20 min"
  /// - >= 60 min: "1 h" or "1 h 30 min"
  ///
  /// Examples:
  /// - 20 → "20 min"
  /// - 45 → "45 min"
  /// - 60 → "1 h"
  /// - 90 → "1 h 30 min"
  /// - 120 → "2 h"
  /// - 150 → "2 h 30 min"
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
