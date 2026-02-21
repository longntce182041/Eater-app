const aiService = require("../services/ai.services");
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
    if (days < 1 || days > 30) {
      return res.status(400).json({
        success: false,
        message: "Days must be between 1 and 30",
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
        data: result.mealPlan,
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

module.exports = {
  generateMealPlan,
  getUserMealPlans,
  getRecommendedRecipes,
  getUserDataForAI,
  checkAIServiceHealth,
  getAIServiceStatus,
  analyzeUserProfile,
};
