const { User_Profile } = require("../../models/User_Profile");
const { DietaryReferences } = require("../../models/dietary_references");
const { MealPlan } = require("../../models/meal_plans");
const { MealPlanItem } = require("../../models/meal_plan_item");
const { UserHealthMetrics } = require("../../models/user_heath_metrics");
const { Recipe } = require("../../models/Recipe");
const aiClient = require("../../integrations/ai/aiClient");
const recipeService = require("./recipe.service");
const mongoose = require("mongoose");

/**
 * Fetch user profile data
 * @param {string} userId - User ID
 * @returns {Promise<Object>} User profile
 */
async function getUserProfile(userId) {
  try {
    const profile = await User_Profile.findOne({ userId });
    if (!profile) {
      throw new Error(`User profile not found for userId: ${userId}`);
    }
    return profile;
  } catch (error) {
    console.error("Error fetching user profile:", error);
    throw error;
  }
}

/**
 * Fetch user dietary preferences
 * @param {string} userId - User ID
 * @returns {Promise<Object>} Dietary preferences
 */
async function getUserDietaryPreferences(userId) {
  try {
    const preferences = await DietaryReferences.findOne({ userId });
    return preferences || {};
  } catch (error) {
    console.error("Error fetching dietary preferences:", error);
    throw error;
  }
}

/**
 * Fetch user health metrics
 * @param {string} userId - User ID
 * @returns {Promise<Object>} Health metrics
 */
async function getUserHealthMetrics(userId) {
  try {
    const metrics = await UserHealthMetrics.findOne({ userId }).sort({
      calculatedAt: -1,
    });
    return metrics || null;
  } catch (error) {
    console.error("Error fetching health metrics:", error);
    throw error;
  }
}

/**
 * Prepare user data for AI service
 * @param {string} userId - User ID
 * @returns {Promise<Object>} Formatted user data
 */
async function prepareUserDataForAI(userId) {
  try {
    const [profile, preferences, healthMetrics] = await Promise.all([
      getUserProfile(userId),
      getUserDietaryPreferences(userId),
      getUserHealthMetrics(userId),
    ]);

    return {
      userId: userId.toString(),
      profile: {
        age: profile.age,
        gender: profile.gender,
        height: profile.height,
        weight: profile.weight,
        goalWeight: profile.goal_weight,
        healthGoals: profile.healthGoals,
      },
      dietaryPreferences: {
        dietTypeId: preferences.dietTypeId || null,
        allergens: preferences.allergens || [],
        restrictions: preferences.restrictions || [],
        excludedIngredients: preferences.excludedIngredients || [],
      },
      healthMetrics: healthMetrics
        ? {
            bmi: healthMetrics.bmi,
            bmr: healthMetrics.bmr,
            tdee: healthMetrics.tdee,
          }
        : null,
    };
  } catch (error) {
    console.error("Error preparing user data for AI:", error);
    throw error;
  }
}

/**
 * Generate meal plan using AI service
 * @param {string} userId - User ID
 * @param {number} days - Number of days for meal plan (default: 7)
 * @param {boolean} useML - Whether to use ML/LLM features (default: false)
 * @returns {Promise<Object>} Generated meal plan
 */
async function generateAIMealPlan(userId, days = 7, useML = false) {
  try {
    // Prepare user data and recipes in parallel
    const [userData, recipes] = await Promise.all([
      prepareUserDataForAI(userId),
      recipeService.getRecipesForAI(),
    ]);

    // Debug: Log user data
    console.log("User data for Gemini:", JSON.stringify(userData, null, 2));

    // Compose user profile for Gemini
    const userProfile = {
      age: userData.profile?.age,
      gender: userData.profile?.gender,
      height: userData.profile?.height,
      weight: userData.profile?.weight,
      goalWeight: userData.profile?.goalWeight,
      healthGoals: userData.profile?.healthGoals,
      dietTypes: userData.dietaryPreferences?.dietTypeId
        ? [userData.dietaryPreferences.dietTypeId]
        : [],
      allergens: userData.dietaryPreferences?.allergens || [],
      restrictions: userData.dietaryPreferences?.restrictions || [],
      excludedIngredients:
        userData.dietaryPreferences?.excludedIngredients || [],
      healthMetrics: userData.healthMetrics || {},
    };

    // Call Gemini client directly
    const {
      requestAIMealPlan,
    } = require("../../integrations/ai/aiMealPlan.service");
    const geminiResult = await requestAIMealPlan({
      userProfile,
      recipeDatabase: recipes,
      days,
    });
    return geminiResult;
    const response = await aiClient.generateMealPlan(payload);

    console.log("Received meal plan from AI service");

    return response.data;
  } catch (error) {
    console.error("Error generating AI meal plan:", error.message);
    if (error.response) {
      console.error("AI Service error response:", error.response.data);
    }
    throw new Error(`Failed to generate meal plan: ${error.message}`);
  }
}

/**
 * Map user health goals to AI service HealthGoalType enum
 */
function mapHealthGoal(healthGoals) {
  if (!healthGoals) return "maintain";

  const goal = healthGoals.toLowerCase();
  if (goal.includes("lose") || goal.includes("loss")) return "weight_loss";
  if (goal.includes("gain") || goal.includes("muscle")) return "muscle_gain";
  if (goal.includes("maintain")) return "maintain";

  return "maintain"; // default
}

/**
 * Save AI-generated meal plan to database
 * @param {string} userId - User ID
 * @param {Object} aiMealPlan - Meal plan data from AI pipeline
 * @param {Object} options - Additional options
 * @returns {Promise<Object>} Saved meal plan with items
 */
async function saveAIMealPlanToDatabase(userId, aiMealPlan, options = {}) {
  try {
    // Debug: Log the AI response structure
    console.log("AI Meal Plan Response:", JSON.stringify(aiMealPlan, null, 2));

    // Extract meal plan data - handle both old and new response formats
    const mealPlanData = aiMealPlan.meal_plan || aiMealPlan;
    const meals = mealPlanData.meals || [];
    const daysData = mealPlanData.days || [];

    console.log(`Found ${meals.length} meals in response`);
    console.log(`Found ${Array.isArray(daysData) ? daysData.length : 0} days`);

    // Use meals array from AI response
    let allMeals = meals.length > 0 ? meals : [];
    let numDays = options.days || 7;

    // If flat array is empty, try to extract from days structure
    if (
      allMeals.length === 0 &&
      Array.isArray(daysData) &&
      daysData.length > 0
    ) {
      allMeals = daysData.flatMap((day) => day.meals || []);
      numDays = options.days || daysData.length;
    }

    // AI now generates all meals for N days with variety
    // No need to repeat or duplicate
    console.log(
      `AI generated ${allMeals.length} meals for ${numDays} days (${Math.ceil(allMeals.length / 4)} meals/typical day)`,
    );

    // Calculate totals
    const totalCalories = allMeals.reduce(
      (sum, meal) => sum + (meal.calories || meal.estimated_calories || 0),
      0,
    );
    const avgCaloriesPerDay = totalCalories / numDays;

    // Create main meal plan document
    const mealPlan = new MealPlan({
      userId: new mongoose.Types.ObjectId(userId),
      date: options.startDate || new Date(),
      days: numDays,
      targetCalories:
        aiMealPlan.goal_profile?.target_calories ||
        mealPlanData.daily_calories ||
        avgCaloriesPerDay,
      actualCalories: avgCaloriesPerDay,
      dietTypes:
        aiMealPlan.diet_constraints?.diet_types || options.dietTypes || [],
      healthGoal: aiMealPlan.goal_profile?.primary_goal || options.healthGoal,
      status: "active",
      aiGenerated: true,
      metadata: {
        pipelineVersion: aiMealPlan.pipeline_metadata?.pipeline_version,
        stepsExecuted: aiMealPlan.pipeline_metadata?.steps_executed,
        candidateRecipes:
          aiMealPlan.pipeline_metadata?.generation_metadata
            ?.candidate_recipes_count,
        calorieMatchAccuracy:
          aiMealPlan.pipeline_metadata?.generation_metadata
            ?.calorie_match_percentage,
        generatedAt: new Date(),
      },
    });

    await mealPlan.save();
    console.log(`✅ Meal plan saved with ID: ${mealPlan._id}`);

    // Save meal plan items
    const mealPlanItems = [];

    // Always distribute meals across days evenly
    // This ensures clear Day 1, Day 2, Day 3... separation
    const mealsPerDay = Math.ceil(allMeals.length / numDays);

    console.log(
      `Distribution: ${allMeals.length} meals ÷ ${numDays} days = ${mealsPerDay} meals per day`,
    );

    for (let i = 0; i < allMeals.length; i++) {
      const meal = allMeals[i];
      // Calculate which day this meal belongs to
      const dayIndex = Math.floor(i / mealsPerDay);

      // Verify dayIndex is within bounds
      if (dayIndex >= numDays) {
        console.warn(
          `⚠️ Meal ${i} assigned to day ${dayIndex}, but only ${numDays} days requested`,
        );
      }

      // Convert recipe_id from string to ObjectId if needed
      let recipeObjectId;
      try {
        recipeObjectId = new mongoose.Types.ObjectId(meal.recipe_id);
      } catch (error) {
        console.warn(`⚠️ Invalid recipe ID: ${meal.recipe_id}, skipping meal`);
        continue;
      }

      const mealItem = new MealPlanItem({
        mealPlanId: mealPlan._id,
        recipeId: recipeObjectId,
        mealType: meal.meal_type?.toLowerCase() || "snack",
        servings: meal.servings || 1,
        calories: meal.calories || meal.estimated_calories || 0,
        protein: meal.protein_g || 0,
        carbohydrates: meal.carbs_g || 0,
        fat: meal.fat_g || 0,
        dayIndex: dayIndex,
      });

      await mealItem.save();
      mealPlanItems.push(mealItem);

      console.log(`  ✓ Meal ${i + 1}: ${meal.meal_type} → Day ${dayIndex + 1}`);
    }

    console.log(`✅ Saved ${mealPlanItems.length} meal plan items`);

    return {
      success: true,
      mealPlan: mealPlan.toObject(),
      items: mealPlanItems.map((item) => item.toObject()),
      summary: {
        totalMeals: mealPlanItems.length,
        days: numDays,
        avgCaloriesPerDay: avgCaloriesPerDay,
      },
    };
  } catch (error) {
    console.error("❌ Error saving meal plan to database:", error);
    throw new Error(`Failed to save meal plan: ${error.message}`);
  }
}

/**
 * Save generated meal plan to database (legacy function - kept for backward compatibility)
 * @param {string} userId - User ID
 * @param {Object} mealPlanData - Meal plan data from AI service
 * @returns {Promise<Object>} Saved meal plan
 */
async function saveMealPlan(userId, mealPlanData) {
  try {
    const mealPlan = new MealPlan({
      userId,
      date: new Date(),
      ...mealPlanData,
      status: "active", // Override any status from AI service with valid enum value
      aiGenerated: true, // Mark as AI-generated meal plan
    });

    await mealPlan.save();
    console.log(`Meal plan saved for user: ${userId}`);

    return mealPlan;
  } catch (error) {
    console.error("Error saving meal plan:", error);
    throw error;
  }
}

/**
 * Get user's meal plans
 * @param {string} userId - User ID
 * @param {number} limit - Number of plans to retrieve (default: 10)
 * @returns {Promise<Array>} Array of meal plans
 */
async function getUserMealPlans(userId, limit = 10) {
  try {
    const plans = await MealPlan.find({ userId })
      .sort({ createdAt: -1 })
      .limit(limit)
      .lean();

    return plans;
  } catch (error) {
    console.error("Error fetching user meal plans:", error);
    throw error;
  }
}

/**
 * Get latest meal plan with items and recipe info
 * @param {string} userId - User ID
 * @returns {Promise<Object|null>} Latest meal plan payload or null
 */
async function getLatestMealPlanWithItems(userId) {
  try {
    const plan = await MealPlan.findOne({ userId })
      .sort({ createdAt: -1 })
      .lean();

    if (!plan) {
      return null;
    }

    const items = await MealPlanItem.find({ mealPlanId: plan._id })
      .populate("recipeId", "name imageUrl")
      .lean();

    const macroTotals = items.reduce(
      (acc, item) => {
        const protein = Number(item.protein) || 0;
        const carbs = Number(item.carbohydrates) || 0;
        const fat = Number(item.fat) || 0;

        acc.protein_g += protein;
        acc.carbs_g += carbs;
        acc.fat_g += fat;
        return acc;
      },
      { protein_g: 0, carbs_g: 0, fat_g: 0 },
    );

    const proteinCalories = macroTotals.protein_g * 4;
    const carbsCalories = macroTotals.carbs_g * 4;
    const fatCalories = macroTotals.fat_g * 9;
    const totalMacroCalories = proteinCalories + carbsCalories + fatCalories;

    const macroDistribution = {
      ...macroTotals,
      protein_percent: totalMacroCalories
        ? (proteinCalories / totalMacroCalories) * 100
        : 0,
      carbs_percent: totalMacroCalories
        ? (carbsCalories / totalMacroCalories) * 100
        : 0,
      fat_percent: totalMacroCalories
        ? (fatCalories / totalMacroCalories) * 100
        : 0,
      total_macro_calories: totalMacroCalories,
    };

    return {
      mealPlan: plan,
      items,
      summary: {
        totalMeals: items.length,
        days: plan.days || 1,
        avgCaloriesPerDay: plan.actualCalories || 0,
        macroDistribution,
      },
    };
  } catch (error) {
    console.error("Error fetching latest meal plan:", error);
    throw error;
  }
}

/**
 * Delete latest meal plan and its items for a user
 * @param {string} userId - User ID
 * @returns {Promise<Object>} Deletion result
 */
async function deleteLatestMealPlanWithItems(userId) {
  try {
    const plan = await MealPlan.findOne({ userId })
      .sort({ createdAt: -1 })
      .lean();

    if (!plan) {
      return {
        deleted: false,
        message: "No meal plan found to delete",
      };
    }

    const itemsResult = await MealPlanItem.deleteMany({
      mealPlanId: plan._id,
    });

    await MealPlan.deleteOne({ _id: plan._id });

    return {
      deleted: true,
      mealPlanId: plan._id.toString(),
      itemsDeleted: itemsResult.deletedCount || 0,
    };
  } catch (error) {
    console.error("Error deleting latest meal plan:", error);
    throw error;
  }
}

/**
 * Delete a meal plan by id and its items
 * @param {string} userId - User ID
 * @param {string} mealPlanId - Meal plan ID
 * @returns {Promise<Object>} Deletion result
 */
async function deleteMealPlanByIdWithItems(userId, mealPlanId) {
  try {
    const plan = await MealPlan.findOne({ _id: mealPlanId, userId }).lean();

    if (!plan) {
      return {
        deleted: false,
        message: "Meal plan not found",
      };
    }

    const itemsResult = await MealPlanItem.deleteMany({
      mealPlanId: plan._id,
    });

    await MealPlan.deleteOne({ _id: plan._id });

    return {
      deleted: true,
      mealPlanId: plan._id.toString(),
      itemsDeleted: itemsResult.deletedCount || 0,
    };
  } catch (error) {
    console.error("Error deleting meal plan by id:", error);
    throw error;
  }
}

/**
 * Delete all meal plans and their items for a user
 * @param {string} userId - User ID
 * @returns {Promise<Object>} Deletion result
 */
async function deleteAllMealPlansWithItems(userId) {
  try {
    const plans = await MealPlan.find({ userId }, { _id: 1 }).lean();
    if (plans.length === 0) {
      return {
        deleted: false,
        message: "No meal plans found to delete",
      };
    }

    const planIds = plans.map((plan) => plan._id);

    const itemsResult = await MealPlanItem.deleteMany({
      mealPlanId: { $in: planIds },
    });

    const plansResult = await MealPlan.deleteMany({
      _id: { $in: planIds },
    });

    return {
      deleted: true,
      plansDeleted: plansResult.deletedCount || 0,
      itemsDeleted: itemsResult.deletedCount || 0,
    };
  } catch (error) {
    console.error("Error deleting all meal plans:", error);
    throw error;
  }
}

/**
 * Delete all meal plans for a user except the given plan id
 * @param {string} userId - User ID
 * @param {string} keepMealPlanId - Meal plan ID to keep
 * @returns {Promise<Object>} Deletion result
 */
async function deleteOtherMealPlansWithItems(userId, keepMealPlanId) {
  try {
    const plans = await MealPlan.find(
      { userId, _id: { $ne: keepMealPlanId } },
      { _id: 1 },
    ).lean();

    if (plans.length === 0) {
      return {
        deleted: false,
        message: "No other meal plans found to delete",
      };
    }

    const planIds = plans.map((plan) => plan._id);

    const itemsResult = await MealPlanItem.deleteMany({
      mealPlanId: { $in: planIds },
    });

    const plansResult = await MealPlan.deleteMany({
      _id: { $in: planIds },
    });

    return {
      deleted: true,
      plansDeleted: plansResult.deletedCount || 0,
      itemsDeleted: itemsResult.deletedCount || 0,
    };
  } catch (error) {
    console.error("Error deleting other meal plans:", error);
    throw error;
  }
}

/**
 * Get recommended recipes based on user preferences
 * @param {string} userId - User ID
 * @param {number} limit - Number of recipes to retrieve (default: 10)
 * @returns {Promise<Array>} Array of recommended recipes
 */
async function getRecommendedRecipes(userId, limit = 10) {
  try {
    const preferences = await getUserDietaryPreferences(userId);

    // Build query based on preferences
    const query = {};

    if (preferences.dietTypeId) {
      query.dietTypeId = preferences.dietTypeId;
    }

    // Exclude recipes with allergens or restricted ingredients
    if (
      preferences.excludedIngredients &&
      preferences.excludedIngredients.length > 0
    ) {
      query.ingredients = {
        $nin: preferences.excludedIngredients,
      };
    }

    const recipes = await Recipe.find(query)
      .sort({ rating: -1 })
      .limit(limit)
      .lean();

    // Transform recipes to AI service format
    const transformedRecipes = recipes.map(recipe => ({
      id: recipe._id.toString(),
      name: recipe.name,
      calories_per_serving: recipe.nutritionInfo?.calories || recipe.baseServings || 400,
      protein_g: recipe.nutritionInfo?.protein || 0,
      carbs_g: recipe.nutritionInfo?.carbs || 0,
      fat_g: recipe.nutritionInfo?.fat || 0,
      ingredients: recipe.ingredients || [],
      diet_types: recipe.dietTypes || [],
      rating: recipe.rating || 0,
      review_count: recipe.reviewCount || 0,
      // Keep original fields for reference
      ...recipe
    }));

    return transformedRecipes;
  } catch (error) {
    console.error("Error fetching recommended recipes:", error);
    throw error;
  }
}

/**
 * Complete workflow: Generate and save meal plan
 * @param {string} userId - User ID
 * @param {Object} options - Options for meal plan generation
 * @returns {Promise<Object>} Saved meal plan with metadata
 */
async function generateAndSaveMealPlan(userId, options = {}) {
  try {
    const { days = 7 } = options;

    console.log(`Starting meal plan generation for user: ${userId}`);

    // Generate meal plan using Gemini only
    const aiMealPlan = await generateAIMealPlan(userId, days);

    // Save meal plan and items to database
    const result = await saveAIMealPlanToDatabase(userId, aiMealPlan, {
      days,
    });

    // Keep only the newest meal plan after regeneration
    await deleteOtherMealPlansWithItems(userId, result.mealPlan._id);

    return {
      success: true,
      mealPlan: result.mealPlan,
      items: result.items,
      summary: result.summary,
      message: "Meal plan generated and saved successfully",
    };
  } catch (error) {
    console.error("Error in generateAndSaveMealPlan:", error);
    return {
      success: false,
      error: error.message,
      message: "Failed to generate and save meal plan",
    };
  }
}

/**
 * Analyze user profile and calculate health metrics (BMR, TDEE, BMI)
 * Following the sequence diagram flow
 * @param {string} userId - User ID
 * @returns {Promise<Object>} Analysis result with health metrics
 */
async function analyzeUserProfileAndSave(userId) {
  try {
    console.log(`Starting user profile analysis for user: ${userId}`);

    // Step 1: Load user profile + health data from DB
    const userProfile = await getUserProfile(userId);

    if (!userProfile) {
      throw new Error(`User profile not found for userId: ${userId}`);
    }

    // Prepare data for AI service
    const profileData = {
      user_id: userId,
      age: userProfile.age,
      gender: userProfile.gender,
      height_cm: userProfile.height,
      weight_kg: userProfile.weight,
      goal_weight_kg: userProfile.goalWeight || userProfile.weight,
      health_goals: userProfile.healthGoals || "maintenance",
      activity_level: userProfile.activityLevel || "moderate",
    };

    console.log(`Sending profile data to AI service:`, profileData);

    // Step 2-4: Call AI API -> AI Core -> Rule Engine/ML
    const analysisResult = await aiClient.analyzeUserProfile(profileData);

    console.log(`Received analysis result from AI:`, analysisResult);

    // Step 5: Save analysis result to DB
    const healthMetrics = new UserHealthMetrics({
      userId: userId,
      bmi: analysisResult.bmi,
      bmr: analysisResult.health_metrics.bmr,
      tdee: analysisResult.health_metrics.tdee,
      body_category: analysisResult.bmi_category.replace("_", ""),
      calculatedAt: new Date(),
      source: analysisResult.source || "AI",
    });

    const savedMetrics = await healthMetrics.save();

    console.log(`Health metrics saved successfully for user: ${userId}`);

    return {
      success: true,
      data: {
        metrics: savedMetrics,
        analysis: analysisResult,
      },
      message: "User profile analyzed and metrics saved successfully",
    };
  } catch (error) {
    console.error("Error in analyzeUserProfileAndSave:", error);
    return {
      success: false,
      error: error.message,
      message: "Failed to analyze user profile",
    };
  }
}

/**
 * Generate meal plan preview (without saving to database)
 * @param {string} userId - User ID for context
 * @param {Object} aiMealPlan - AI response with meal plan data
 * @param {Object} options - Options including days
 * @returns {Promise<Object>} Preview data with meals organized by day
 */
async function generateMealPlanPreview(userId, aiMealPlan, options = {}) {
  try {
    console.log("📋 Generating meal plan preview (not saving to DB)");

    // Extract meal plan data - handle both old and new response formats
    const mealPlanData = aiMealPlan.meal_plan || aiMealPlan;
    const meals = mealPlanData.meals || [];
    const daysData = mealPlanData.days || [];

    // Use meals array from AI response
    let allMeals = meals.length > 0 ? meals : [];
    let numDays = options.days || 7;

    // If flat array is empty, try to extract from days structure
    if (
      allMeals.length === 0 &&
      Array.isArray(daysData) &&
      daysData.length > 0
    ) {
      allMeals = daysData.flatMap((day) => day.meals || []);
      numDays = options.days || daysData.length;
    }

    console.log(`Preview: ${allMeals.length} meals for ${numDays} days`);

    // Calculate totals
    const totalCalories = allMeals.reduce(
      (sum, meal) => sum + (meal.calories || meal.estimated_calories || 0),
      0,
    );
    const avgCaloriesPerDay = totalCalories / numDays;

    // Organize meals by day for preview
    const mealsPerDay = Math.ceil(allMeals.length / numDays);
    const mealsByDay = [];

    for (let dayIdx = 0; dayIdx < numDays; dayIdx++) {
      const dayMeals = [];
      for (let mealIdx = 0; mealIdx < mealsPerDay; mealIdx++) {
        const mealIndex = dayIdx * mealsPerDay + mealIdx;
        if (mealIndex < allMeals.length) {
          const meal = allMeals[mealIndex];
          dayMeals.push({
            id: `${dayIdx}_${mealIdx}`, // Temporary ID for preview
            mealType: meal.meal_type?.toLowerCase() || "snack",
            name: meal.name || meal.recipe_name || "Meal",
            calories: meal.calories || meal.estimated_calories || 0,
            protein: meal.protein_g || 0,
            carbs: meal.carbs_g || 0,
            fat: meal.fat_g || 0,
            servings: meal.servings || 1,
            recipeId: meal.recipe_id,
            dayIndex: dayIdx,
            selected: true, // Default to selected for preview
          });
        }
      }
      mealsByDay.push({
        dayNumber: dayIdx + 1,
        meals: dayMeals,
        dayCalories: dayMeals.reduce((sum, m) => sum + m.calories, 0),
      });
    }

    return {
      success: true,
      preview: {
        mealsByDay,
        totalMeals: allMeals.length,
        days: numDays,
        totalCalories,
        avgCaloriesPerDay,
        dietTypes:
          aiMealPlan.diet_constraints?.diet_types || options.dietTypes || [],
        healthGoal: aiMealPlan.goal_profile?.primary_goal || options.healthGoal,
      },
      allMeals, // Keep original meals for later save
    };
  } catch (error) {
    console.error("❌ Error generating meal plan preview:", error);
    throw new Error(`Failed to generate preview: ${error.message}`);
  }
}

/**
 * Save modified meals from preview to database (with replacements)
 * @param {string} userId - User ID
 * @param {Object} aiMealPlan - Original AI response
 * @param {Object} modifiedMeals - Modified meals object {mealId: mealData}
 * @param {Object} options - Options including days
 * @returns {Promise<Object>} Saved meal plan with items
 */
async function saveModifiedMealsFromPreview(
  userId,
  aiMealPlan,
  modifiedMeals = {},
  options = {},
) {
  try {
    console.log(`💾 Saving modified meals for user ${userId}`);

    const numDays = options.days || 7;

    // Convert modifiedMeals object to array and sort by mealId (dayIndex_mealIndex)
    const mealsArray = Object.entries(modifiedMeals)
      .sort((a, b) => {
        const [aDayIdx, aMealIdx] = a[0].split("_").map(Number);
        const [bDayIdx, bMealIdx] = b[0].split("_").map(Number);
        return aDayIdx === bDayIdx ? aMealIdx - bMealIdx : aDayIdx - bDayIdx;
      })
      .map(([mealId, mealData]) => {
        const [dayIdx, mealIdx] = mealId.split("_").map(Number);
        return {
          ...mealData,
          dayIndex: dayIdx,
        };
      });

    console.log(`Saving ${mealsArray.length} meals (including replacements)`);

    const totalCalories = mealsArray.reduce(
      (sum, meal) => sum + (meal.calories || 0),
      0,
    );
    const avgCaloriesPerDay = totalCalories / numDays;

    // Create meal plan
    const mealPlan = new MealPlan({
      userId: new mongoose.Types.ObjectId(userId),
      date: options.startDate || new Date(),
      days: numDays,
      targetCalories:
        aiMealPlan.goal_profile?.target_calories || avgCaloriesPerDay,
      actualCalories: avgCaloriesPerDay,
      dietTypes: options.dietTypes || [],
      healthGoal: aiMealPlan.goal_profile?.primary_goal || options.healthGoal,
      status: "active",
      aiGenerated: true,
      metadata: {
        pipelineVersion: aiMealPlan.pipeline_metadata?.pipeline_version,
        stepsExecuted: aiMealPlan.pipeline_metadata?.steps_executed,
        generatedAt: new Date(),
        hasReplacements: mealsArray.some((m) => m.isReplaced),
      },
    });

    await mealPlan.save();
    console.log(`✅ Meal plan saved with ID: ${mealPlan._id}`);

    // Save meal plan items
    const mealPlanItems = [];

    for (const meal of mealsArray) {
      let recipeObjectId;
      try {
        recipeObjectId = new mongoose.Types.ObjectId(meal.recipeId);
      } catch (error) {
        console.warn(`⚠️ Invalid recipe ID: ${meal.recipeId}, skipping meal`);
        continue;
      }

      const mealItem = new MealPlanItem({
        mealPlanId: mealPlan._id,
        recipeId: recipeObjectId,
        mealType: meal.mealType?.toLowerCase() || "snack",
        servings: meal.servings || 1,
        calories: meal.calories || 0,
        protein: meal.protein || 0,
        carbohydrates: meal.carbs || 0,
        fat: meal.fat || 0,
        dayIndex: meal.dayIndex,
      });

      await mealItem.save();
      mealPlanItems.push(mealItem);
    }

    console.log(`✅ Saved ${mealPlanItems.length} meal plan items`);

    return {
      success: true,
      mealPlan: mealPlan.toObject(),
      items: mealPlanItems.map((item) => item.toObject()),
      summary: {
        totalMeals: mealPlanItems.length,
        days: numDays,
        avgCaloriesPerDay: avgCaloriesPerDay,
      },
    };
  } catch (error) {
    console.error("❌ Error saving modified meals:", error);
    throw new Error(`Failed to save meals: ${error.message}`);
  }
}

/**
 * Save selected meals from preview to database
 * @param {string} userId - User ID
 * @param {Object} aiMealPlan - Original AI response
 * @param {Array} selectedMealIds - IDs of meals to save (format: "dayIdx_mealIdx")
 * @param {Object} options - Options including days
 * @returns {Promise<Object>} Saved meal plan with items
 */
async function saveSelectedMealsFromPreview(
  userId,
  aiMealPlan,
  selectedMealIds = [],
  options = {},
) {
  try {
    console.log(`💾 Saving selected meals for user ${userId}`);

    // Extract meal plan data
    const mealPlanData = aiMealPlan.meal_plan || aiMealPlan;
    const meals = mealPlanData.meals || [];
    const daysData = mealPlanData.days || [];

    let allMeals = meals.length > 0 ? meals : [];
    let numDays = options.days || 7;

    if (
      allMeals.length === 0 &&
      Array.isArray(daysData) &&
      daysData.length > 0
    ) {
      allMeals = daysData.flatMap((day) => day.meals || []);
      numDays = options.days || daysData.length;
    }

    // If selectedMealIds is empty, save all (backward compatibility)
    let mealsToSave = allMeals;
    if (selectedMealIds && selectedMealIds.length > 0) {
      const selectedIndexes = selectedMealIds.map((id) => {
        const [dayIdx, mealIdx] = id.split("_").map(Number);
        const mealsPerDay = Math.ceil(allMeals.length / numDays);
        return dayIdx * mealsPerDay + mealIdx;
      });

      mealsToSave = allMeals.filter((_, idx) => selectedIndexes.includes(idx));
    }

    console.log(`Saving ${mealsToSave.length} out of ${allMeals.length} meals`);

    const totalCalories = mealsToSave.reduce(
      (sum, meal) => sum + (meal.calories || meal.estimated_calories || 0),
      0,
    );
    const avgCaloriesPerDay = totalCalories / numDays;

    // Create meal plan
    const mealPlan = new MealPlan({
      userId: new mongoose.Types.ObjectId(userId),
      date: options.startDate || new Date(),
      days: numDays,
      targetCalories:
        aiMealPlan.goal_profile?.target_calories ||
        mealPlanData.daily_calories ||
        avgCaloriesPerDay,
      actualCalories: avgCaloriesPerDay,
      dietTypes:
        aiMealPlan.diet_constraints?.diet_types || options.dietTypes || [],
      healthGoal: aiMealPlan.goal_profile?.primary_goal || options.healthGoal,
      status: "active",
      aiGenerated: true,
      metadata: {
        pipelineVersion: aiMealPlan.pipeline_metadata?.pipeline_version,
        stepsExecuted: aiMealPlan.pipeline_metadata?.steps_executed,
        generatedAt: new Date(),
      },
    });

    await mealPlan.save();
    console.log(`✅ Meal plan saved with ID: ${mealPlan._id}`);

    // Save meal plan items
    const mealPlanItems = [];
    const mealsPerDay = Math.ceil(mealsToSave.length / numDays);

    for (let i = 0; i < mealsToSave.length; i++) {
      const meal = mealsToSave[i];
      const dayIndex = Math.floor(i / mealsPerDay);

      let recipeObjectId;
      try {
        recipeObjectId = new mongoose.Types.ObjectId(meal.recipe_id);
      } catch (error) {
        console.warn(`⚠️ Invalid recipe ID: ${meal.recipe_id}, skipping meal`);
        continue;
      }

      const mealItem = new MealPlanItem({
        mealPlanId: mealPlan._id,
        recipeId: recipeObjectId,
        mealType: meal.meal_type?.toLowerCase() || "snack",
        servings: meal.servings || 1,
        calories: meal.calories || meal.estimated_calories || 0,
        protein: meal.protein_g || 0,
        carbohydrates: meal.carbs_g || 0,
        fat: meal.fat_g || 0,
        dayIndex: dayIndex,
      });

      await mealItem.save();
      mealPlanItems.push(mealItem);
    }

    console.log(`✅ Saved ${mealPlanItems.length} meal plan items`);

    return {
      success: true,
      mealPlan: mealPlan.toObject(),
      items: mealPlanItems.map((item) => item.toObject()),
      summary: {
        totalMeals: mealPlanItems.length,
        days: numDays,
        avgCaloriesPerDay: avgCaloriesPerDay,
      },
    };
  } catch (error) {
    console.error("❌ Error saving selected meals:", error);
    throw new Error(`Failed to save meals: ${error.message}`);
  }
}

module.exports = {
  getUserProfile,
  getUserDietaryPreferences,
  getUserHealthMetrics,
  prepareUserDataForAI,
  generateAIMealPlan,
  saveMealPlan,
  saveAIMealPlanToDatabase,
  getUserMealPlans,
  getLatestMealPlanWithItems,
  deleteLatestMealPlanWithItems,
  deleteMealPlanByIdWithItems,
  deleteAllMealPlansWithItems,
  deleteOtherMealPlansWithItems,
  getRecommendedRecipes,
  generateAndSaveMealPlan,
  analyzeUserProfileAndSave,
  generateMealPlanPreview,
  saveSelectedMealsFromPreview,
  saveModifiedMealsFromPreview,
};
