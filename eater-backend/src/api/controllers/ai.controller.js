const aiService = require("../services/ai.services");
const recipeService = require("../services/recipe.service");
const aiClient = require("../../integrations/ai/aiClient");
const {
  healthCheck,
  getServiceStatus,
} = require("../../integrations/ai/aiClient");

/**
 * Generate meal plan for user
 * @route POST /api/ai/meal-plan/generate
 */
async function generateMealPlan(req, res) {
  try {
    const userId = req.user?.id || req.body.userId;
    const { days = 7, useML = false } = req.body;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: "User ID is required",
      });
    }

    // Validate days parameter
    if (days < 1 || days > 7) {
      return res.status(400).json({
        success: false,
        message: "Days must be between 1 and 7",
      });
    }

    console.log(
      `Generating meal plan for user ${userId}, days: ${days}, useML: ${useML}`,
    );

    const result = await aiService.generateAndSaveMealPlan(userId, {
      days,
      useML,
    });

    if (result.success) {
      return res.status(201).json({
        success: true,
        message: result.message,
        data: {
          mealPlan: result.mealPlan,
          items: result.items,
          summary: result.summary,
        },
      });
    } else {
      return res.status(500).json({
        success: false,
        message: result.message,
        error: result.error,
      });
    }
  } catch (error) {
    console.error("Error in generateMealPlan controller:", error);
    return res.status(500).json({
      success: false,
      message: "Failed to generate meal plan",
      error: error.message,
    });
  }
}

/**
 * Get user's meal plans
 * @route GET /api/ai/meal-plans
 */
async function getUserMealPlans(req, res) {
  try {
    const userId = req.user?.id || req.query.userId;
    const limit = parseInt(req.query.limit) || 10;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: "User ID is required",
      });
    }

    const mealPlans = await aiService.getUserMealPlans(userId, limit);

    return res.status(200).json({
      success: true,
      count: mealPlans.length,
      data: mealPlans,
    });
  } catch (error) {
    console.error("Error in getUserMealPlans controller:", error);
    return res.status(500).json({
      success: false,
      message: "Failed to fetch meal plans",
      error: error.message,
    });
  }
}

/**
 * Get user's latest meal plan with items
 * @route GET /api/ai/meal-plans/latest
 */
async function getLatestMealPlan(req, res) {
  try {
    const userId = req.user?.id || req.query.userId;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: "User ID is required",
      });
    }

    const latest = await aiService.getLatestMealPlanWithItems(userId);

    return res.status(200).json({
      success: true,
      data: latest,
    });
  } catch (error) {
    console.error("Error in getLatestMealPlan controller:", error);
    return res.status(500).json({
      success: false,
      message: "Failed to fetch latest meal plan",
      error: error.message,
    });
  }
}

/**
 * Get recommended recipes for user
 * @route GET /api/ai/recipes/recommended
 */
async function getRecommendedRecipes(req, res) {
  try {
    const userId = req.user?.id || req.query.userId;
    const limit = parseInt(req.query.limit) || 10;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: "User ID is required",
      });
    }

    const recipes = await aiService.getRecommendedRecipes(userId, limit);

    return res.status(200).json({
      success: true,
      count: recipes.length,
      data: recipes,
    });
  } catch (error) {
    console.error("Error in getRecommendedRecipes controller:", error);
    return res.status(500).json({
      success: false,
      message: "Failed to fetch recommended recipes",
      error: error.message,
    });
  }
}

/**
 * Get user data prepared for AI
 * @route GET /api/ai/user-data
 */
async function getUserDataForAI(req, res) {
  try {
    const userId = req.user?.id || req.query.userId;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: "User ID is required",
      });
    }

    const userData = await aiService.prepareUserDataForAI(userId);

    return res.status(200).json({
      success: true,
      data: userData,
    });
  } catch (error) {
    console.error("Error in getUserDataForAI controller:", error);
    return res.status(500).json({
      success: false,
      message: "Failed to fetch user data",
      error: error.message,
    });
  }
}

/**
 * Check AI service health
 * @route GET /api/ai/health
 */
async function checkAIServiceHealth(req, res) {
  try {
    const health = await healthCheck();
    return res.status(200).json({
      success: true,
      data: health,
    });
  } catch (error) {
    console.error("Error in checkAIServiceHealth controller:", error);
    return res.status(503).json({
      success: false,
      message: "AI service is unavailable",
      error: error.message,
    });
  }
}

/**
 * Get AI service status
 * @route GET /api/ai/status
 */
async function getAIServiceStatus(req, res) {
  try {
    const status = await getServiceStatus();
    return res.status(200).json({
      success: true,
      data: status,
    });
  } catch (error) {
    console.error("Error in getAIServiceStatus controller:", error);
    return res.status(500).json({
      success: false,
      message: "Failed to get AI service status",
      error: error.message,
    });
  }
}

/**
 * Analyze user profile and calculate health metrics
 * @route POST /api/ai/user-profile/analyze
 */
async function analyzeUserProfile(req, res) {
  try {
    const userId = req.user?.id || req.body.userId;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: "User ID is required",
      });
    }

    console.log(`Analyzing profile for user ${userId}`);

    const result = await aiService.analyzeUserProfileAndSave(userId);

    if (result.success) {
      return res.status(200).json({
        success: true,
        message: result.message,
        data: result.data,
      });
    } else {
      return res.status(500).json({
        success: false,
        message: result.message,
        error: result.error,
      });
    }
  } catch (error) {
    console.error("Error in analyzeUserProfile controller:", error);
    return res.status(500).json({
      success: false,
      message: "Failed to analyze user profile",
      error: error.message,
    });
  }
}

/**
 * Save AI-generated meal plan to database
 * @route POST /api/ai/meal-plan/save
 */
async function saveMealPlanFromAI(req, res) {
  try {
    const userId = req.user?.id || req.body.userId;
    const { mealPlan, options } = req.body;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: "User ID is required",
      });
    }

    if (!mealPlan) {
      return res.status(400).json({
        success: false,
        message: "Meal plan data is required",
      });
    }

    console.log(`Saving AI-generated meal plan for user ${userId}`);

    const result = await aiService.saveAIMealPlanToDatabase(
      userId,
      mealPlan,
      options || {},
    );

    return res.status(201).json({
      success: true,
      message: "Meal plan saved successfully",
      data: result,
    });
  } catch (error) {
    console.error("Error saving meal plan:", error);
    return res.status(500).json({
      success: false,
      message: "Failed to save meal plan",
      error: error.message,
    });
  }
}

/**
 * Complete meal plan generation - All-in-one endpoint
 * Analyzes profile -> Fetches recipes -> Generates meal plan -> Saves to database
 * @route POST /api/ai/meal-plan/generate-complete
 */
async function generateCompleteMealPlan(req, res) {
  try {
    const {
      userId,
      age,
      gender,
      height_cm,
      weight_kg,
      goal_weight_kg,
      health_goals,
      activity_level,
      dietTypes = [],
      allergies = [],
      disliked_ingredients = [],
      days = 1,
    } = req.body;

    // Validation
    if (
      !userId ||
      !age ||
      !gender ||
      !height_cm ||
      !weight_kg ||
      !goal_weight_kg ||
      !health_goals ||
      !activity_level
    ) {
      return res.status(400).json({
        success: false,
        message:
          "Missing required fields: userId, age, gender, height_cm, weight_kg, goal_weight_kg, health_goals, activity_level",
      });
    }

    console.log(`🚀 Starting complete meal plan generation for user ${userId}`);

    // Step 1: Analyze user profile
    console.log("📊 Step 1: Analyzing user profile...");
    const profileResponse = await aiClient.analyzeUserProfile({
      user_id: userId,
      age,
      gender,
      height_cm,
      weight_kg,
      goal_weight_kg,
      health_goals,
      activity_level,
    });

    const body_profile = {
      age: age,
      gender: gender,
      bmi: profileResponse.bmi,
      bmr: profileResponse.health_metrics.bmr,
      tdee: profileResponse.health_metrics.tdee,
      activity_level: activity_level,
    };

    console.log(
      `✅ Profile analyzed - BMR: ${body_profile.bmr}, TDEE: ${body_profile.tdee}, BMI: ${body_profile.bmi}`,
    );

    // Step 2: Fetch recipes from MongoDB
    console.log("🗄️  Step 2: Fetching recipes from MongoDB...");
    console.log("Diet types requested:", dietTypes);
    const recipes = await recipeService.getRecipesForAI({
      dietTypes: dietTypes.length > 0 ? dietTypes : undefined,
    });
    console.log(`Recipe count after fetch: ${recipes.length}`);

    if (recipes.length === 0) {
      return res.status(404).json({
        success: false,
        message: "No recipes found in database. Please add recipes first.",
      });
    }

    console.log(`✅ Fetched ${recipes.length} recipes from database`);

    // Step 3: Generate meal plan with AI
    console.log("🍽️  Step 3: Generating meal plan with AI...");
    const mealPlanResult = await aiClient.generateMealPlanPipeline({
      user_id: userId,
      body_profile: body_profile,
      diet_types: dietTypes,
      allergies: allergies,
      disliked_ingredients: disliked_ingredients,
      health_goal: health_goals,
      days: days,
      recipe_database: recipes,
    });

    console.log(
      `✅ Meal plan generated with ${mealPlanResult.meal_plan?.meals?.length || 0} meals`,
    );

    // Step 4: Save to database
    console.log("💾 Step 4: Saving meal plan to database...");
    const savedResult = await aiService.saveAIMealPlanToDatabase(
      userId,
      mealPlanResult,
      {
        dietTypes: dietTypes,
        healthGoal: health_goals,
        days: days,
        startDate: new Date(),
      },
    );

    console.log(`✅ Meal plan saved with ID: ${savedResult.mealPlan._id}`);

    return res.status(201).json({
      success: true,
      message: "Meal plan generated and saved successfully",
      data: {
        profile: {
          bmi: body_profile.bmi,
          bmr: body_profile.bmr,
          tdee: body_profile.tdee,
          bmi_category: profileResponse.bmi_category,
        },
        mealPlan: savedResult.mealPlan,
        items: savedResult.items,
        summary: {
          totalMeals: savedResult.summary.totalMeals,
          days: savedResult.summary.days,
          avgCaloriesPerDay: savedResult.summary.avgCaloriesPerDay,
          recipesUsed: recipes.length,
        },
      },
    });
  } catch (error) {
    console.error("❌ Error in complete meal plan generation:", error);
    return res.status(500).json({
      success: false,
      message: "Failed to generate meal plan",
      error: error.message,
    });
  }
}

module.exports = {
  generateMealPlan,
  getUserMealPlans,
  getLatestMealPlan,
  getRecommendedRecipes,
  getUserDataForAI,
  checkAIServiceHealth,
  getAIServiceStatus,
  analyzeUserProfile,
  saveMealPlanFromAI,
  generateCompleteMealPlan,
};
