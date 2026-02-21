const express = require("express");
const router = express.Router();
const aiController = require("../controllers/ai.controller");
const aiValidators = require("../validators/ai.validators");
// const authMiddleware = require("../../middleware/auth"); // Uncomment if auth is needed

/**
 * @route   POST /api/ai/meal-plan/generate
 * @desc    Generate AI meal plan for user
 * @access  Private (requires authentication)
 */
router.post(
  "/meal-plan/generate",
  // authMiddleware, // Uncomment to require authentication
  aiValidators.validateMealPlanGeneration,
  aiController.generateMealPlan,
);

/**
 * @route   GET /api/ai/meal-plans
 * @desc    Get user's meal plans
 * @access  Private
 */
router.get(
  "/meal-plans",
  // authMiddleware,
  aiValidators.validateGetMealPlans,
  aiController.getUserMealPlans,
);

/**
 * @route   GET /api/ai/recipes/recommended
 * @desc    Get recommended recipes for user
 * @access  Private
 */
router.get(
  "/recipes/recommended",
  // authMiddleware,
  aiValidators.validateGetRecommendedRecipes,
  aiController.getRecommendedRecipes,
);

/**
 * @route   GET /api/ai/user-data
 * @desc    Get user data formatted for AI service
 * @access  Private
 */
router.get(
  "/user-data",
  // authMiddleware,
  aiValidators.validateGetUserData,
  aiController.getUserDataForAI,
);

/**
 * @route   GET /api/ai/health
 * @desc    Check AI service health
 * @access  Public
 */
router.get("/health", aiController.checkAIServiceHealth);

/**
 * @route   GET /api/ai/status
 * @desc    Get AI service status
 * @access  Public
 */
router.get("/status", aiController.getAIServiceStatus);

/**
 * @route   POST /api/ai/user-profile/analyze
 * @desc    Analyze user profile and calculate health metrics (BMR, TDEE, BMI)
 * @access  Private
 */
router.post(
  "/user-profile/analyze",
  // authMiddleware,
  aiValidators.validateAnalyzeUserProfile,
  aiController.analyzeUserProfile,
);

module.exports = router;
