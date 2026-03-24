const express = require("express");
const router = express.Router();
const aiController = require("../controllers/ai.controller");
const aiValidators = require("../validators/ai.validators");
const { protect } = require("../../middleware/authMiddleware");

/**
 * @route   POST /api/ai/meal-plan/generate
 * @desc    Generate AI meal plan for user
 * @access  Private (requires authentication)
 */
router.post(
  "/meal-plan/generate",
  protect,
  aiValidators.validateMealPlanGeneration,
  aiController.generateMealPlan,
);

/**
 * @route   POST /api/ai/meal-plan/save
 * @desc    Save AI-generated meal plan to database
 * @access  Private
 */
router.post(
  "/meal-plan/save",
  // authMiddleware,
  aiController.saveMealPlanFromAI,
);

/**
 * @route   POST /api/ai/meal-plan/generate-complete
 * @desc    Complete meal plan generation - Analyzes profile, fetches recipes, generates plan, and saves to DB
 * @access  Private
 */
router.post(
  "/meal-plan/generate-complete",
  // authMiddleware,
  aiController.generateCompleteMealPlan,
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
 * @route   DELETE /api/ai/meal-plans
 * @desc    Delete all meal plans for user
 * @access  Private
 */
router.delete(
  "/meal-plans",
  protect,
  aiController.deleteAllMealPlans,
);

/**
 * @route   GET /api/ai/meal-plans/latest
 * @desc    Get user's latest meal plan with items
 * @access  Private
 */
router.get(
  "/meal-plans/latest",
  protect,
  aiController.getLatestMealPlan,
);

/**
 * @route   DELETE /api/ai/meal-plans/latest
 * @desc    Delete user's latest meal plan and items
 * @access  Private
 */
router.delete(
  "/meal-plans/latest",
  protect,
  aiController.deleteLatestMealPlan,
);

/**
 * @route   DELETE /api/ai/meal-plans/:id
 * @desc    Delete user's meal plan by id and items
 * @access  Private
 */
router.delete(
  "/meal-plans/:id",
  protect,
  aiController.deleteMealPlanById,
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
 * @route   POST /api/ai/meal-plan/preview
 * @desc    Generate meal plan preview (no database save, returns preview data)
 * @access  Private
 */
router.post(
  "/meal-plan/preview",
  // authMiddleware,
  aiController.generateMealPlanPreview,
);

/**
 * @route   POST /api/ai/meal-plan/save-preview
 * @desc    Save selected meals from preview to database
 * @access  Private
 */
router.post(
  "/meal-plan/save-preview",
  // authMiddleware,
  aiController.saveMealPlanFromPreview,
);

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
