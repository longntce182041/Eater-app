const { User_Profile } = require("../../models/User_Profile");
const { DietaryReferences } = require("../../models/dietary_references");
const { MealPlan } = require("../../models/meal_plans");
const { UserHealthMetrics } = require("../../models/user_heath_metrics");
const { Recipe } = require("../../models/Recipe");
const aiClient = require("../../integrations/ai/aiClient");

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
    // Prepare user data
    const userData = await prepareUserDataForAI(userId);

    // Create request payload
    const payload = {
      user_id: userId.toString(),
      days: days,
      use_ml: useML,
      user_data: userData,
    };

    console.log("Sending meal plan generation request to AI service:", {
      userId,
      days,
      useML,
    });

    // Call AI service
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
 * Save generated meal plan to database
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

    return recipes;
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
    const { days = 7, useML = false } = options;

    console.log(`Starting meal plan generation for user: ${userId}`);

    // Generate meal plan using AI service
    const aiMealPlan = await generateAIMealPlan(userId, days, useML);

    // Save meal plan to database
    const savedMealPlan = await saveMealPlan(userId, aiMealPlan);

    return {
      success: true,
      mealPlan: savedMealPlan,
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

module.exports = {
  getUserProfile,
  getUserDietaryPreferences,
  getUserHealthMetrics,
  prepareUserDataForAI,
  generateAIMealPlan,
  saveMealPlan,
  getUserMealPlans,
  getRecommendedRecipes,
  generateAndSaveMealPlan,
  analyzeUserProfileAndSave,
};
