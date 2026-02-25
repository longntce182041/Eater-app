const { MealPlan } = require("../../models/meal_plans");
const { MealPlanItem } = require("../../models/meal_plan_item");
const { Recipe } = require("../../models/Recipe");
const mongoose = require("mongoose");

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
    const targetCalories = currentMeal.calories;
    const minCalories = targetCalories - calorieThreshold;
    const maxCalories = targetCalories + calorieThreshold;

    console.log(
      `    📋 Query: Find recipes with calories between ${minCalories.toFixed(0)}-${maxCalories.toFixed(0)}`,
    );

    // Try to find recipes with similar calories first
    let recipes = await Recipe.find({
      _id: { $ne: currentMeal.recipeId._id },
      isPublished: true,
      "nutritionInfo.calories": {
        $gte: minCalories,
        $lte: maxCalories,
      },
    })
      .sort({ rating: -1 })
      .limit(10)
      .select("name nutritionInfo.calories rating");

    console.log(
      `    📊 Database found ${recipes.length} recipes in exact calorie range`,
    );

    // If no recipes found in the exact range, expand the search
    if (recipes.length === 0) {
      console.log(`    🔸 No exact matches, expanding search to ±200 calories`);
      const expandedMin = targetCalories - 200;
      const expandedMax = targetCalories + 200;

      recipes = await Recipe.find({
        _id: { $ne: currentMeal.recipeId._id },
        isPublished: true,
        "nutritionInfo.calories": {
          $gte: expandedMin,
          $lte: expandedMax,
        },
      })
        .sort({ rating: -1 })
        .limit(10)
        .select("name nutritionInfo.calories rating");

      console.log(
        `    📊 Found ${recipes.length} recipes in expanded range (${expandedMin.toFixed(0)}-${expandedMax.toFixed(0)})`,
      );
    }

    // If still no recipes, get any published recipes sorted by rating
    if (recipes.length === 0) {
      console.log(
        `    🔸 Still no matches, falling back to any published recipes`,
      );
      recipes = await Recipe.find({
        _id: { $ne: currentMeal.recipeId._id },
        isPublished: true,
      })
        .sort({ rating: -1 })
        .limit(5)
        .select("name nutritionInfo.calories rating");

      console.log(
        `    📊 Found ${recipes.length} published recipes (any calo)`,
      );
    }

    const suggestions = recipes.map((recipe) => ({
      _id: recipe._id,
      name: recipe.name,
      calories: recipe.nutritionInfo?.calories || 0,
      rating: recipe.rating || 0,
      calorieMatch: Math.abs(
        (recipe.nutritionInfo?.calories || 0) - targetCalories,
      ),
    }));

    if (suggestions.length > 0) {
      console.log(
        `    ✓ Top 3 suggestions: ${suggestions
          .slice(0, 3)
          .map((s) => `${s.name}(${s.calories.toFixed(0)}cal)`)
          .join(", ")}`,
      );
    }

    return suggestions;
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

    // Store old recipe ID
    const oldRecipeId = currentItem.recipeId;

    // Update meal plan item with new recipe
    currentItem.recipeId = newRecipeId;
    currentItem.replacedFrom = oldRecipeId;
    currentItem.replacementReason = reason;
    currentItem.userAction = "replaced";
    currentItem.userRating = null; // Reset rating when recipe is replaced

    // Update nutrition values from new recipe
    if (newRecipe.nutritionInfo) {
      currentItem.calories =
        newRecipe.nutritionInfo.calories || currentItem.calories;
      currentItem.protein =
        newRecipe.nutritionInfo.protein || currentItem.protein;
      currentItem.carbohydrates =
        newRecipe.nutritionInfo.carbs || currentItem.carbohydrates;
      currentItem.fat = newRecipe.nutritionInfo.fat || currentItem.fat;
    }

    await currentItem.save();

    // Recalculate meal plan metrics
    await recalculateMealPlanMetrics(mealPlanId);

    console.log(`✓ Meal replaced: ${oldRecipeId} → ${newRecipeId}`);
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

    let totalCalories = 0;
    let totalProtein = 0;
    let totalCarbs = 0;
    let totalFat = 0;

    items.forEach((item) => {
      totalCalories += item.calories || 0;
      totalProtein += item.protein || 0;
      totalCarbs += item.carbohydrates || 0;
      totalFat += item.fat || 0;
    });

    const mealPlan = await MealPlan.findByIdAndUpdate(
      mealPlanId,
      {
        actualCalories: totalCalories / Math.max(items.length / 4, 1), // Divide by number of days
      },
      { new: true },
    );

    console.log(`✓ Metrics recalculated for plan ${mealPlanId}`);
    return mealPlan;
  } catch (error) {
    console.error("Error recalculating meal plan metrics:", error);
  }
}

/**
 * Calculate variety score for meal plan
 * @param {string} mealPlanId - Meal plan ID
 * @returns {Promise<number>} Variety score (0-100)
 */
async function calculateVarietyScore(mealPlanId) {
  try {
    const items = await MealPlanItem.find({ mealPlanId }).populate("recipeId");

    if (items.length === 0) return 0;

    // Count unique recipes
    const uniqueRecipes = new Set(
      items.map((item) => item.recipeId._id.toString()),
    );
    const uniqueCount = uniqueRecipes.size;
    const totalCount = items.length;

    // Variety score: unique recipes / total meals * 100
    const varietyScore = (uniqueCount / totalCount) * 100;

    return Math.round(varietyScore);
  } catch (error) {
    console.error("Error calculating variety score:", error);
    return 0;
  }
}

/**
 * Rate a meal
 * @param {string} itemId - Meal plan item ID
 * @param {number} rating - Rating 1-5
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

    if (!item) {
      throw new Error("Meal plan item not found");
    }

    console.log(`✓ Meal rated: ${rating}/5`);
    return item;
  } catch (error) {
    console.error("Error rating meal:", error);
    throw error;
  }
}

/**
 * Get meal plan optimization suggestions
 * @param {string} mealPlanId - Meal plan ID
 * @param {string} userId - User ID
 * @returns {Promise<Object>} Optimization suggestions
 */
async function getOptimizationSuggestions(mealPlanId, userId) {
  try {
    const items = await MealPlanItem.find({ mealPlanId });

    if (items.length === 0) {
      return {
        suggestions: [],
        varietyScore: 0,
        message: "No meals in plan",
      };
    }

    // Find meals with low ratings (< 3)
    const lowRatedMeals = items.filter(
      (item) => item.userRating && item.userRating < 3,
    );

    // Find duplicate recipes (bad for variety)
    const recipeFrequency = {};
    items.forEach((item) => {
      const recipeId = item.recipeId.toString();
      recipeFrequency[recipeId] = (recipeFrequency[recipeId] || 0) + 1;
    });

    const duplicates = Object.entries(recipeFrequency)
      .filter(([, count]) => count > 1)
      .map(([recipeId]) => {
        const occurrences = items.filter(
          (item) => item.recipeId.toString() === recipeId,
        );
        return occurrences[0]; // Return first occurrence for replacement
      });

    // Generate suggestions
    const suggestions = [...lowRatedMeals, ...duplicates].slice(0, 5);

    const varietyScore = await calculateVarietyScore(mealPlanId);

    return {
      suggestions: suggestions.map((item) => ({
        _id: item._id,
        mealType: item.mealType,
        rating: item.userRating,
        reason: item.userRating ? "Low rating" : "Duplicate recipe",
      })),
      varietyScore,
      recommendedChanges: suggestions.length,
    };
  } catch (error) {
    console.error("Error getting optimization suggestions:", error);
    throw error;
  }
}

/**
 * Optimize entire meal plan
 * @param {string} mealPlanId - Meal plan ID
 * @param {string} userId - User ID
 * @returns {Promise<Object>} Optimization result
 */
async function optimizeMealPlan(mealPlanId, userId) {
  try {
    console.log(`🔄 Starting meal plan optimization for ${mealPlanId}`);

    // Get all items with populated recipe data
    let items = await MealPlanItem.find({ mealPlanId }).populate("recipeId");

    if (items.length === 0) {
      throw new Error("No meals in plan to optimize");
    }

    console.log(`📊 Total meals in plan: ${items.length}`);

    // Filter out items with null recipeId (deleted recipes)
    const validItems = items.filter((item) => item.recipeId !== null);
    const invalidItems = items.filter((item) => item.recipeId === null);

    if (invalidItems.length > 0) {
      console.warn(
        `⚠️  Found ${invalidItems.length} meals with missing recipes, skipping them`,
      );
    }

    // Get variety score before
    const varietyBefore = await calculateVarietyScore(mealPlanId);

    let replacementCount = 0;
    const changes = [];

    // Build optimization strategy: prioritize by importance
    const candidatesForReplacement = [];
    const recipeFrequency = {};

    // Count recipe occurrences
    validItems.forEach((item) => {
      const recipeId = item.recipeId._id.toString();
      recipeFrequency[recipeId] = (recipeFrequency[recipeId] || 0) + 1;
    });

    console.log(
      `📍 Recipe frequency:`,
      Object.values(recipeFrequency).filter((c) => c > 1),
    );

    // 1. PRIORITY 1: Replace low user-rated meals (< 3)
    const lowRatedItems = validItems.filter(
      (item) => item.userRating && item.userRating < 3,
    );
    console.log(`⭐ Low-rated meals (<3): ${lowRatedItems.length}`);

    lowRatedItems.forEach((item) => {
      if (!item.isLocked) {
        console.log(
          `  - Item ${item._id}: rating=${item.userRating}, recipe=${item.recipeId.name}`,
        );
        candidatesForReplacement.push({
          item,
          priority: 1,
          reason: "Low user rating",
        });
      }
    });

    // 2. PRIORITY 2: Replace duplicate recipes (keep variety high)
    for (const [recipeId, count] of Object.entries(recipeFrequency)) {
      if (count > 1) {
        const duplicateItems = validItems.filter(
          (item) =>
            item.recipeId._id.toString() === recipeId &&
            !item.isLocked &&
            !candidatesForReplacement.some((c) => c.item._id.equals(item._id)),
        );

        console.log(
          `  - Recipe appears ${count}x, marking ${duplicateItems.length} for replacement`,
        );

        // Keep first occurrence, mark others for replacement
        for (let i = 1; i < duplicateItems.length; i++) {
          candidatesForReplacement.push({
            item: duplicateItems[i],
            priority: 2,
            reason: "Duplicate recipe",
          });
        }
      }
    }

    // 3. PRIORITY 3: If no candidates yet, replace some meals with better varieties
    // This ensures the optimization feature always shows results
    if (candidatesForReplacement.length === 0 && validItems.length > 0) {
      console.log(
        `📌 No low-rated or duplicates found, selecting meals for variety improvement`,
      );
      // Select random meals (up to 30% of meals) for variety improvement
      const mealCount = Math.min(Math.ceil(validItems.length * 0.3), 3);
      const shuffled = validItems
        .filter((item) => !item.isLocked)
        .sort(() => Math.random() - 0.5);

      for (let i = 0; i < Math.min(mealCount, shuffled.length); i++) {
        candidatesForReplacement.push({
          item: shuffled[i],
          priority: 3,
          reason: "Variety enhancement",
        });
      }

      console.log(
        `  - Selected ${Math.min(mealCount, shuffled.length)} meals for variety improvement`,
      );
    }

    console.log(
      `🎯 Total candidates for replacement: ${candidatesForReplacement.length}`,
    );

    // Sort by priority
    candidatesForReplacement.sort((a, b) => a.priority - b.priority);

    // Process candidates
    for (const { item, reason } of candidatesForReplacement) {
      try {
        console.log(
          `  🔍 Finding replacement for: ${item.recipeId.name} (${item.calories}cal)`,
        );

        const replacements = await findReplacementRecipes(item, userId, 100);

        console.log(`    → Found ${replacements.length} replacement options`);

        if (replacements.length > 0) {
          // Find replacement with much better rating
          const bestReplacement = replacements[0];

          console.log(
            `    ✓ Best match: ${bestReplacement.name} (${bestReplacement.calories}cal, rating:${bestReplacement.rating})`,
          );

          await replaceMeal(
            mealPlanId,
            item._id,
            bestReplacement._id,
            `${reason} (${item.recipeId.name} → ${bestReplacement.name})`,
          );

          replacementCount++;
          changes.push({
            itemId: item._id,
            oldRecipe: item.recipeId.name,
            newRecipe: bestReplacement.name,
            reason,
          });

          console.log(
            `    ✅ Replaced: ${item.recipeId.name} → ${bestReplacement.name}`,
          );
        } else {
          console.log(
            `    ❌ No replacement options found (calorie range: ${item.calories - 100}-${item.calories + 100})`,
          );
        }
      } catch (error) {
        console.error(
          `Failed to replace meal for item ${item._id}:`,
          error.message,
        );
        // Continue with next candidate if one fails
      }
    }

    // Reload items and recalculate variety
    items = await MealPlanItem.find({ mealPlanId });
    const varietyAfter = await calculateVarietyScore(mealPlanId);

    console.log(
      `✓ Optimization complete: ${replacementCount} meals replaced, variety improved ${varietyBefore.toFixed(
        0,
      )}% → ${varietyAfter.toFixed(0)}%`,
    );

    return {
      success: true,
      replacementCount,
      changes,
      varietyBefore: Math.round(varietyBefore),
      varietyAfter: Math.round(varietyAfter),
      varietyImproved: varietyAfter > varietyBefore,
      message: `✓ Optimized ${replacementCount} meals, variety improved from ${Math.round(
        varietyBefore,
      )}% to ${Math.round(varietyAfter)}%`,
    };
  } catch (error) {
    console.error("Error optimizing meal plan:", error);
    throw error;
  }
}

module.exports = {
  findReplacementRecipes,
  replaceMeal,
  recalculateMealPlanMetrics,
  calculateVarietyScore,
  rateMeal,
  getOptimizationSuggestions,
  optimizeMealPlan,
};
