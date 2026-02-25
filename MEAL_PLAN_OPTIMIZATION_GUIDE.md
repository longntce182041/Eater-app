# Meal Plan Optimization Implementation Guide

## 📌 Overview

Task: **Optimize Meal Plan** - "Adjust the meal plan for better optimization"

This guide provides a complete implementation plan for adding meal plan optimization capabilities to the Eater app, allowing users to customize and improve their AI-generated meal plans.

---

## 🎯 Optimization Goals

### Primary Goals:

1. **User Flexibility**: Allow users to replace meals they don't like
2. **Nutritional Balance**: Maintain calorie and macro targets when replacing
3. **Variety Improvement**: Ensure diverse recipes across the week
4. **Preference Learning**: Track user choices for better future recommendations

### Success Metrics:

- User satisfaction with meal plans (tracked through actions)
- Meal plan completion rate
- Recipe variety score (unique recipes / total meals)
- Calorie target deviation (actual vs target)

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Mobile UI                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Replace Meal │  │ Rate Meal    │  │ Optimize All │      │
│  │   Button     │  │   Stars      │  │   Button     │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
└─────────┼─────────────────┼─────────────────┼──────────────┘
          │                 │                 │
          ▼                 ▼                 ▼
┌─────────────────────────────────────────────────────────────┐
│                    Backend API Layer                         │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  PATCH /api/meal-plans/:id/items/:itemId/replace     │ │
│  │  POST  /api/meal-plans/:id/items/:itemId/rate        │ │
│  │  POST  /api/meal-plans/:id/optimize                   │ │
│  │  GET   /api/meal-plans/:id/suggestions?mealType=...  │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────────────────────────┐
│                   Optimization Service                       │
│  ┌──────────────────┐  ┌──────────────────┐                │
│  │  Recipe Matcher  │  │ Nutrition Balancer│                │
│  │  - Similar cals  │  │ - Macro ratios    │                │
│  │  - Same meal type│  │ - Calorie targets │                │
│  │  - Diet compat   │  │ - Balance check   │                │
│  └──────────────────┘  └──────────────────┘                 │
│  ┌──────────────────┐  ┌──────────────────┐                │
│  │ Variety Scorer   │  │ Preference Learner│                │
│  │ - Unique recipes │  │ - Track actions   │                │
│  │ - Diverse ingred │  │ - Pattern analysis│                │
│  └──────────────────┘  └──────────────────┘                 │
└─────────────────────────────────────────────────────────────┘
```

---

## 📊 Phase 1: Database Schema Updates

### A. Update MealPlanItem Model

**File:** `eater-backend/src/models/meal_plan_item.js`

```javascript
const mealPlanItemSchema = new mongoose.Schema(
  {
    // ... existing fields ...

    // NEW FIELDS FOR OPTIMIZATION
    userRating: {
      type: Number,
      min: 1,
      max: 5,
      default: null,
    },
    userAction: {
      type: String,
      enum: ["none", "saved", "replaced", "disliked", "completed"],
      default: "none",
    },
    replacedFrom: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Recipe",
      default: null,
    },
    replacementReason: {
      type: String,
      default: null,
    },
    isLocked: {
      type: Boolean,
      default: false,
      // When true, this meal won't be changed during optimization
    },
  },
  { timestamps: true },
);
```

### B. Create Optimization Log Model (Optional)

**File:** `eater-backend/src/models/meal_plan_optimization_log.js`

```javascript
const mongoose = require("mongoose");

const optimizationLogSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    mealPlanId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "MealPlan",
      required: true,
    },
    optimizationType: {
      type: String,
      enum: ["manual_replace", "auto_optimize", "regenerate_with_constraints"],
      required: true,
    },
    changesCount: {
      type: Number,
      default: 0,
    },
    beforeMetrics: {
      totalCalories: Number,
      varietyScore: Number,
      avgRating: Number,
    },
    afterMetrics: {
      totalCalories: Number,
      varietyScore: Number,
      avgRating: Number,
    },
    improvedMetrics: [String], // ['variety', 'calories', 'preferences']
  },
  { timestamps: true },
);

const MealPlanOptimizationLog = mongoose.model(
  "MealPlanOptimizationLog",
  optimizationLogSchema,
);

module.exports = { MealPlanOptimizationLog };
```

---

## 🔧 Phase 2: Backend Services

### A. Meal Plan Optimization Service

**File:** `eater-backend/src/api/services/meal.plan.optimization.service.js`

```javascript
const { MealPlan } = require("../../models/meal_plans");
const { MealPlanItem } = require("../../models/meal_plan_item");
const { Recipe } = require("../../models/Recipe");
const { getUserDietaryPreferences } = require("./ai.services");

/**
 * Find similar recipes for meal replacement
 * @param {Object} currentMeal - Current MealPlanItem
 * @param {string} userId - User ID for dietary preferences
 * @param {number} calorieThreshold - +/- calorie range (default: 100)
 * @returns {Promise<Array>} Array of suggested recipes
 */
async function findReplacementRecipes(
  currentMeal,
  userId,
  calorieThreshold = 100,
) {
  try {
    // Get user dietary preferences
    const preferences = await getUserDietaryPreferences(userId);

    // Build query
    const query = {
      _id: { $ne: currentMeal.recipeId }, // Exclude current recipe
    };

    // Filter by dietary preferences
    if (preferences.excludedIngredients?.length > 0) {
      query.ingredients = { $nin: preferences.excludedIngredients };
    }

    // Find recipes with similar calories
    const targetCalories = currentMeal.calories;
    const minCalories = targetCalories - calorieThreshold;
    const maxCalories = targetCalories + calorieThreshold;

    const recipes = await Recipe.aggregate([
      { $match: query },
      {
        $addFields: {
          calorieDiff: {
            $abs: {
              $subtract: [
                { $ifNull: ["$nutritionInfo.calories", 500] },
                targetCalories,
              ],
            },
          },
        },
      },
      { $match: { calorieDiff: { $lte: calorieThreshold } } },
      { $sort: { calorieDiff: 1, rating: -1 } },
      { $limit: 10 },
    ]);

    return recipes;
  } catch (error) {
    console.error("Error finding replacement recipes:", error);
    throw error;
  }
}

/**
 * Replace a meal in meal plan
 * @param {string} mealPlanId - Meal plan ID
 * @param {string} itemId - Meal plan item ID
 * @param {string} newRecipeId - New recipe ID
 * @param {string} reason - Replacement reason
 * @returns {Promise<Object>} Updated meal plan item
 */
async function replaceMeal(mealPlanId, itemId, newRecipeId, reason = null) {
  try {
    // Get current item
    const currentItem = await MealPlanItem.findOne({
      _id: itemId,
      mealPlanId,
    });

    if (!currentItem) {
      throw new Error("Meal plan item not found");
    }

    // Get new recipe info
    const newRecipe = await Recipe.findById(newRecipeId);
    if (!newRecipe) {
      throw new Error("New recipe not found");
    }

    // Update meal plan item
    const oldRecipeId = currentItem.recipeId;
    currentItem.recipeId = newRecipeId;
    currentItem.replacedFrom = oldRecipeId;
    currentItem.replacementReason = reason;
    currentItem.userAction = "replaced";

    // Update nutrition values from new recipe
    currentItem.calories =
      newRecipe.nutritionInfo?.calories || currentItem.calories;
    currentItem.protein =
      newRecipe.nutritionInfo?.protein || currentItem.protein;
    currentItem.carbohydrates =
      newRecipe.nutritionInfo?.carbohydrates || currentItem.carbohydrates;
    currentItem.fat = newRecipe.nutritionInfo?.fat || currentItem.fat;

    await currentItem.save();

    // Recalculate meal plan totals
    await recalculateMealPlanMetrics(mealPlanId);

    return currentItem;
  } catch (error) {
    console.error("Error replacing meal:", error);
    throw error;
  }
}

/**
 * Recalculate meal plan metrics after changes
 * @param {string} mealPlanId - Meal plan ID
 */
async function recalculateMealPlanMetrics(mealPlanId) {
  try {
    const items = await MealPlanItem.find({ mealPlanId });

    const totalCalories = items.reduce((sum, item) => sum + item.calories, 0);
    const days =
      items.length > 0 ? Math.max(...items.map((i) => i.dayIndex)) + 1 : 1;
    const avgCalories = totalCalories / days;

    await MealPlan.findByIdAndUpdate(mealPlanId, {
      actualCalories: avgCalories,
    });
  } catch (error) {
    console.error("Error recalculating meal plan metrics:", error);
  }
}

/**
 * Calculate variety score for meal plan
 * @param {string} mealPlanId - Meal plan ID
 * @returns {Promise<number>} Variety score (0-1)
 */
async function calculateVarietyScore(mealPlanId) {
  try {
    const items = await MealPlanItem.find({ mealPlanId });

    const uniqueRecipes = new Set(
      items.map((item) => item.recipeId.toString()),
    );
    const varietyScore = uniqueRecipes.size / items.length;

    return varietyScore;
  } catch (error) {
    console.error("Error calculating variety score:", error);
    return 0;
  }
}

/**
 * Optimize entire meal plan
 * - Replace low-rated meals
 * - Improve variety
 * - Maintain calorie targets
 * @param {string} mealPlanId - Meal plan ID
 * @param {string} userId - User ID
 * @returns {Promise<Object>} Optimization result
 */
async function optimizeMealPlan(mealPlanId, userId) {
  try {
    const mealPlan = await MealPlan.findById(mealPlanId);
    if (!mealPlan) {
      throw new Error("Meal plan not found");
    }

    const items = await MealPlanItem.find({ mealPlanId });

    // Find candidates for replacement
    const replacementCandidates = items.filter((item) => {
      return (
        (!item.isLocked && item.userRating && item.userRating < 3) || // Low rated
        item.userAction === "disliked" // Explicitly disliked
      );
    });

    console.log(`Found ${replacementCandidates.length} meals to optimize`);

    let replacedCount = 0;
    const changes = [];

    for (const candidate of replacementCandidates) {
      // Find replacement
      const suggestions = await findReplacementRecipes(candidate, userId, 150);

      if (suggestions.length > 0) {
        const bestMatch = suggestions[0];

        await replaceMeal(
          mealPlanId,
          candidate._id,
          bestMatch._id,
          "auto_optimization",
        );

        replacedCount++;
        changes.push({
          oldRecipe: candidate.recipeId,
          newRecipe: bestMatch._id,
          reason: "low_rating_or_disliked",
        });
      }
    }

    // Recalculate metrics
    await recalculateMealPlanMetrics(mealPlanId);
    const varietyScore = await calculateVarietyScore(mealPlanId);

    return {
      success: true,
      replacedCount,
      changes,
      newVarietyScore: varietyScore,
      message: `Optimized ${replacedCount} meals`,
    };
  } catch (error) {
    console.error("Error optimizing meal plan:", error);
    throw error;
  }
}

/**
 * Rate a meal
 * @param {string} itemId - Meal plan item ID
 * @param {number} rating - Rating (1-5)
 * @returns {Promise<Object>} Updated item
 */
async function rateMeal(itemId, rating) {
  try {
    if (rating < 1 || rating > 5) {
      throw new Error("Rating must be between 1 and 5");
    }

    const item = await MealPlanItem.findByIdAndUpdate(
      itemId,
      { userRating: rating },
      { new: true },
    );

    return item;
  } catch (error) {
    console.error("Error rating meal:", error);
    throw error;
  }
}

module.exports = {
  findReplacementRecipes,
  replaceMeal,
  recalculateMealPlanMetrics,
  calculateVarietyScore,
  optimizeMealPlan,
  rateMeal,
};
```

---

## 🌐 Phase 3: Backend API Endpoints

### A. Controller

**File:** `eater-backend/src/api/controllers/meal.plan.optimization.controller.js`

```javascript
const optimizationService = require("../services/meal.plan.optimization.service");

/**
 * Get replacement suggestions for a meal
 * @route GET /api/meal-plans/:planId/items/:itemId/suggestions
 */
async function getReplacementSuggestions(req, res) {
  try {
    const { planId, itemId } = req.params;
    const userId = req.user?.id;

    if (!userId) {
      return res.status(401).json({
        success: false,
        message: "Authentication required",
      });
    }

    const { MealPlanItem } = require("../../models/meal_plan_item");
    const item = await MealPlanItem.findOne({
      _id: itemId,
      mealPlanId: planId,
    });

    if (!item) {
      return res.status(404).json({
        success: false,
        message: "Meal not found",
      });
    }

    const suggestions = await optimizationService.findReplacementRecipes(
      item,
      userId,
      150,
    );

    return res.json({
      success: true,
      data: {
        currentMeal: item,
        suggestions,
        count: suggestions.length,
      },
    });
  } catch (error) {
    console.error("Error getting replacement suggestions:", error);
    return res.status(500).json({
      success: false,
      message: "Failed to get suggestions",
      error: error.message,
    });
  }
}

/**
 * Replace a meal in meal plan
 * @route PATCH /api/meal-plans/:planId/items/:itemId/replace
 */
async function replaceMealInPlan(req, res) {
  try {
    const { planId, itemId } = req.params;
    const { newRecipeId, reason } = req.body;

    if (!newRecipeId) {
      return res.status(400).json({
        success: false,
        message: "New recipe ID is required",
      });
    }

    const updatedItem = await optimizationService.replaceMeal(
      planId,
      itemId,
      newRecipeId,
      reason,
    );

    return res.json({
      success: true,
      message: "Meal replaced successfully",
      data: updatedItem,
    });
  } catch (error) {
    console.error("Error replacing meal:", error);
    return res.status(500).json({
      success: false,
      message: "Failed to replace meal",
      error: error.message,
    });
  }
}

/**
 * Optimize entire meal plan
 * @route POST /api/meal-plans/:planId/optimize
 */
async function optimizeEntirePlan(req, res) {
  try {
    const { planId } = req.params;
    const userId = req.user?.id;

    if (!userId) {
      return res.status(401).json({
        success: false,
        message: "Authentication required",
      });
    }

    const result = await optimizationService.optimizeMealPlan(planId, userId);

    return res.json({
      success: true,
      message: result.message,
      data: result,
    });
  } catch (error) {
    console.error("Error optimizing meal plan:", error);
    return res.status(500).json({
      success: false,
      message: "Failed to optimize meal plan",
      error: error.message,
    });
  }
}

/**
 * Rate a meal
 * @route POST /api/meal-plans/:planId/items/:itemId/rate
 */
async function rateMealItem(req, res) {
  try {
    const { itemId } = req.params;
    const { rating } = req.body;

    if (!rating) {
      return res.status(400).json({
        success: false,
        message: "Rating is required",
      });
    }

    const updatedItem = await optimizationService.rateMeal(itemId, rating);

    return res.json({
      success: true,
      message: "Meal rated successfully",
      data: updatedItem,
    });
  } catch (error) {
    console.error("Error rating meal:", error);
    return res.status(500).json({
      success: false,
      message: "Failed to rate meal",
      error: error.message,
    });
  }
}

module.exports = {
  getReplacementSuggestions,
  replaceMealInPlan,
  optimizeEntirePlan,
  rateMealItem,
};
```

### B. Routes

**File:** `eater-backend/src/api/routes/meal.plan.optimization.routes.js`

```javascript
const express = require("express");
const router = express.Router();
const optimizationController = require("../controllers/meal.plan.optimization.controller");
const { protect } = require("../../middleware/authMiddleware");

// All routes require authentication
router.use(protect);

// Get replacement suggestions for a meal
router.get(
  "/:planId/items/:itemId/suggestions",
  optimizationController.getReplacementSuggestions,
);

// Replace a meal
router.patch(
  "/:planId/items/:itemId/replace",
  optimizationController.replaceMealInPlan,
);

// Rate a meal
router.post("/:planId/items/:itemId/rate", optimizationController.rateMealItem);

// Optimize entire plan
router.post("/:planId/optimize", optimizationController.optimizeEntirePlan);

module.exports = router;
```

### C. Register Routes

**Add to:** `eater-backend/app.js` (or wherever routes are registered)

```javascript
const mealPlanOptimizationRoutes = require("./src/api/routes/meal.plan.optimization.routes");

// Register routes
app.use("/api/meal-plans", mealPlanOptimizationRoutes);
```

---

## 📱 Phase 4: Mobile UI Updates

### A. Update Meal Plan Models

**File:** `mobile/lib/src/features/meal_plan/domain/meal_plan_models.dart`

```dart
class MealPlanItemModel {
  final String id;
  final String mealType;
  final int servings;
  final double calories;
  final double protein;
  final double carbohydrates;
  final double fat;
  final int dayIndex;
  final String? recipeName;
  final String? recipeImageUrl;

  // NEW FIELDS
  final int? userRating;
  final String userAction;
  final bool isLocked;

  MealPlanItemModel({
    required this.id,
    required this.mealType,
    required this.servings,
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    required this.dayIndex,
    this.recipeName,
    this.recipeImageUrl,
    this.userRating,
    this.userAction = 'none',
    this.isLocked = false,
  });

  factory MealPlanItemModel.fromJson(Map<String, dynamic> json) {
    final recipe = json['recipeId'] is Map<String, dynamic>
        ? json['recipeId'] as Map<String, dynamic>
        : null;

    return MealPlanItemModel(
      id: json['_id']?.toString() ?? '',
      mealType: json['mealType']?.toString() ?? 'snack',
      servings: (json['servings'] as num?)?.toInt() ?? 1,
      calories: (json['calories'] as num?)?.toDouble() ?? 0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0,
      carbohydrates: (json['carbohydrates'] as num?)?.toDouble() ?? 0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0,
      dayIndex: (json['dayIndex'] as num?)?.toInt() ?? 0,
      recipeName: recipe?['name']?.toString(),
      recipeImageUrl: recipe?['imageUrl']?.toString(),
      userRating: (json['userRating'] as num?)?.toInt(),
      userAction: json['userAction']?.toString() ?? 'none',
      isLocked: json['isLocked'] == true,
    );
  }
}
```

### B. Add API Methods

**File:** `mobile/lib/src/features/meal_plan/data/meal_plan_api_client.dart`

```dart
/// Get replacement suggestions for a meal
Future<List<RecipeModel>> getReplacementSuggestions(
  String planId,
  String itemId,
) async {
  try {
    final response = await _client.get(
      '/api/meal-plans/$planId/items/$itemId/suggestions',
    );

    if (response.statusCode == 200) {
      final data = response.data['data'] as Map<String, dynamic>;
      final suggestions = data['suggestions'] as List;

      return suggestions
          .map((json) => RecipeModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to get suggestions');
    }
  } catch (e) {
    throw Exception('Failed to get replacement suggestions: $e');
  }
}

/// Replace a meal in meal plan
Future<MealPlanItemModel> replaceMeal(
  String planId,
  String itemId,
  String newRecipeId,
  String? reason,
) async {
  try {
    final response = await _client.patch(
      '/api/meal-plans/$planId/items/$itemId/replace',
      data: {
        'newRecipeId': newRecipeId,
        if (reason != null) 'reason': reason,
      },
    );

    if (response.statusCode == 200) {
      final data = response.data['data'] as Map<String, dynamic>;
      return MealPlanItemModel.fromJson(data);
    } else {
      throw Exception('Failed to replace meal');
    }
  } catch (e) {
    throw Exception('Failed to replace meal: $e');
  }
}

/// Optimize entire meal plan
Future<Map<String, dynamic>> optimizeMealPlan(String planId) async {
  try {
    final response = await _client.post(
      '/api/meal-plans/$planId/optimize',
    );

    if (response.statusCode == 200) {
      return response.data['data'] as Map<String, dynamic>;
    } else {
      throw Exception('Failed to optimize meal plan');
    }
  } catch (e) {
    throw Exception('Failed to optimize meal plan: $e');
  }
}

/// Rate a meal
Future<MealPlanItemModel> rateMeal(
  String planId,
  String itemId,
  int rating,
) async {
  try {
    final response = await _client.post(
      '/api/meal-plans/$planId/items/$itemId/rate',
      data: {'rating': rating},
    );

    if (response.statusCode == 200) {
      final data = response.data['data'] as Map<String, dynamic>;
      return MealPlanItemModel.fromJson(data);
    } else {
      throw Exception('Failed to rate meal');
    }
  } catch (e) {
    throw Exception('Failed to rate meal: $e');
  }
}
```

### C. Update Meal Plan Page UI

**File:** `mobile/lib/src/features/meal_plan/presentation/pages/meal_plan_page.dart`

Add these UI components:

```dart
// Add to meal item card
Widget _buildMealItemActions(MealPlanItemModel item, String planId) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      // Rating stars
      IconButton(
        icon: Icon(
          item.userRating != null && item.userRating! > 0
              ? Icons.star
              : Icons.star_border,
          color: const Color(0xFFFF9800),
        ),
        onPressed: () => _showRatingDialog(item, planId),
        tooltip: 'Rate this meal',
      ),

      // Replace button
      IconButton(
        icon: const Icon(Icons.swap_horiz),
        onPressed: () => _showReplacementDialog(item, planId),
        tooltip: 'Replace meal',
      ),
    ],
  );
}

// Rating dialog
void _showRatingDialog(MealPlanItemModel item, String planId) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Rate this meal'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.recipeName ?? 'Meal',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < (item.userRating ?? 0) ? Icons.star : Icons.star_border,
                  color: const Color(0xFFFF9800),
                  size: 32,
                ),
                onPressed: () async {
                  try {
                    await ref
                        .read(mealPlanNotifierProvider.notifier)
                        .rateMeal(planId, item.id, index + 1);

                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Rating saved')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to rate: $e')),
                      );
                    }
                  }
                },
              );
            }),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}

// Replacement dialog
void _showReplacementDialog(MealPlanItemModel item, String planId) async {
  try {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF9800)),
      ),
    );

    // Get suggestions
    final suggestions = await ref
        .read(mealPlanNotifierProvider.notifier)
        .getReplacementSuggestions(planId, item.id);

    if (!mounted) return;
    Navigator.pop(context); // Close loading

    // Show suggestions
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Replace ${item.recipeName}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${item.calories.toInt()} cal • ${item.mealType}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Suggestions list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) {
                    final recipe = suggestions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: recipe.imageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  recipe.imageUrl!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.restaurant),
                              ),
                        title: Text(recipe.name),
                        subtitle: Text(
                          '${recipe.calories?.toInt() ?? 0} cal',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: ElevatedButton(
                          onPressed: () async {
                            try {
                              await ref
                                  .read(mealPlanNotifierProvider.notifier)
                                  .replaceMeal(planId, item.id, recipe.id, 'user_preference');

                              if (!mounted) return;
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Meal replaced!')),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed: $e')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF9800),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Select'),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  } catch (e) {
    if (!mounted) return;
    Navigator.pop(context); // Close loading if open
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to load suggestions: $e')),
    );
  }
}

// Add optimize button to app bar
AppBar(
  // ... existing properties
  actions: [
    IconButton(
      icon: const Icon(Icons.auto_fix_high),
      onPressed: state.result != null && !state.isLoading
          ? () => _onOptimizePressed(state.result!.mealPlan.id)
          : null,
      tooltip: 'Optimize meal plan',
    ),
    if (state.result != null)
      IconButton(
        onPressed: state.isLoading ? null : () => _confirmDelete(context),
        icon: const Icon(Icons.delete_outline),
        color: const Color(0xFFD32F2F),
        tooltip: 'Delete meal plans',
      ),
  ],
)

// Optimize handler
Future<void> _onOptimizePressed(String planId) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Optimize Meal Plan'),
      content: const Text(
        'This will automatically replace low-rated meals with better alternatives. Continue?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF9800),
          ),
          child: const Text('Optimize'),
        ),
      ],
    ),
  );

  if (confirmed == true && mounted) {
    try {
      final result = await ref
          .read(mealPlanNotifierProvider.notifier)
          .optimizeMealPlan(planId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Optimized ${result['replacedCount']} meals'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Optimization failed: $e')),
      );
    }
  }
}
```

---

## 🧪 Phase 5: Testing

### A. Backend API Tests

Create test file: `eater-backend/src/tests/meal.plan.optimization.test.js`

```javascript
const request = require("supertest");
const app = require("../app");
const mongoose = require("mongoose");

describe("Meal Plan Optimization API", () => {
  let authToken;
  let testPlanId;
  let testItemId;

  beforeAll(async () => {
    // Setup: Login and create test meal plan
    // ... implementation
  });

  afterAll(async () => {
    // Cleanup
    await mongoose.connection.close();
  });

  test("GET /api/meal-plans/:planId/items/:itemId/suggestions", async () => {
    const response = await request(app)
      .get(`/api/meal-plans/${testPlanId}/items/${testItemId}/suggestions`)
      .set("Authorization", `Bearer ${authToken}`);

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(Array.isArray(response.body.data.suggestions)).toBe(true);
  });

  test("PATCH /api/meal-plans/:planId/items/:itemId/replace", async () => {
    // ... implementation
  });

  test("POST /api/meal-plans/:planId/items/:itemId/rate", async () => {
    // ... implementation
  });

  test("POST /api/meal-plans/:planId/optimize", async () => {
    // ... implementation
  });
});
```

### B. Manual Testing Checklist

- [ ] Can view meal plan items
- [ ] Rating dialog appears and saves rating
- [ ] Replace button shows suggestions
- [ ] Suggestions match calorie range
- [ ] Meal replacement updates plan correctly
- [ ] Calorie totals recalculate after replacement
- [ ] Optimize button replaces low-rated meals
- [ ] UI reflects changes immediately
- [ ] Error handling works (network errors, not found, etc.)

---

## 📈 Future Enhancements

### Phase 6: Advanced Features (Optional)

1. **AI-Powered Optimization**
   - Call AI service with meal plan + user feedback
   - Let AI suggest better combinations
   - Predict user preferences with ML

2. **Swap Meals Between Days**
   - Drag-and-drop meals across days
   - Reorder meals within a day

3. **Favorite Recipes**
   - Pin favorite recipes to always include
   - "More like this" suggestions

4. **Nutrition Insights**
   - Show macro trends over the week
   - Alert if protein/carbs/fat ratio is off
   - Suggest adjustments for balance

5. **Social Features**
   - Share optimized meal plans
   - Community ratings
   - Popular replacements

---

## 🎯 Success Criteria

### MVP (Minimum Viable Product):

- ✅ User can replace individual meals
- ✅ System suggests similar recipes
- ✅ Meal plan totals update automatically
- ✅ Basic rating system works

### Full Feature:

- ✅ Auto-optimization based on ratings
- ✅ Variety scoring
- ✅ Preference learning
- ✅ Smooth UI/UX

### Excellence:

- ✅ AI-powered suggestions
- ✅ Comprehensive analytics
- ✅ Social features
- ✅ Real-time updates

---

## 📚 Documentation

### API Documentation

Add to `eater-backend/AI_SERVICE_API.md`:

````markdown
## Meal Plan Optimization Endpoints

### Get Replacement Suggestions

**GET** `/api/meal-plans/:planId/items/:itemId/suggestions`

Returns recipes similar to the specified meal that can be used as replacements.

**Response:**

```json
{
  "success": true,
  "data": {
    "currentMeal": {
      /* MealPlanItem */
    },
    "suggestions": [
      /* Array of Recipe */
    ],
    "count": 5
  }
}
```
````

### Replace Meal

**PATCH** `/api/meal-plans/:planId/items/:itemId/replace`

Replaces a meal with a new recipe.

**Request Body:**

```json
{
  "newRecipeId": "507f1f77bcf86cd799439012",
  "reason": "user_preference"
}
```

### Rate Meal

**POST** `/api/meal-plans/:planId/items/:itemId/rate`

**Request Body:**

```json
{
  "rating": 4
}
```

### Optimize Meal Plan

**POST** `/api/meal-plans/:planId/optimize`

Auto-optimizes the meal plan by replacing low-rated meals.

```

---

## 🚀 Implementation Timeline

### Week 1: Backend Foundation
- Day 1-2: Database schema updates
- Day 3-4: Optimization service implementation
- Day 5: API endpoints and testing

### Week 2: Mobile UI
- Day 1-2: API client methods
- Day 3-4: UI components (rating, replacement)
- Day 5: Integration and polish

### Week 3: Testing & Launch
- Day 1-2: End-to-end testing
- Day 3: Bug fixes
- Day 4: Documentation
- Day 5: Deploy to production

---

## 💡 Key Implementation Tips

1. **Start Simple**: Implement manual replacement first, then auto-optimization
2. **User Feedback**: Track all actions (ratings, replacements) for future ML
3. **Performance**: Cache suggestions, optimize database queries
4. **UX**: Make replacement seamless with quick suggestions
5. **Error Handling**: Gracefully handle no suggestions found
6. **Analytics**: Track which meals get replaced most often

---

## 🔗 Related Files

### Backend:
- `eater-backend/src/models/meal_plan_item.js`
- `eater-backend/src/api/services/meal.plan.optimization.service.js`
- `eater-backend/src/api/controllers/meal.plan.optimization.controller.js`
- `eater-backend/src/api/routes/meal.plan.optimization.routes.js`

### Mobile:
- `mobile/lib/src/features/meal_plan/domain/meal_plan_models.dart`
- `mobile/lib/src/features/meal_plan/data/meal_plan_api_client.dart`
- `mobile/lib/src/features/meal_plan/presentation/pages/meal_plan_page.dart`
- `mobile/lib/src/features/meal_plan/presentation/providers/meal_plan_provider.dart`

---

**Created:** February 25, 2026
**Author:** GitHub Copilot
**Project:** Eater App - Meal Plan Optimization Feature
```
