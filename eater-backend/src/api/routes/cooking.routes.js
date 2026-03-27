const express = require("express");
const router = express.Router();
const cookingController = require("../controllers/cooking.controller");
const { protect } = require("../../middleware/authMiddleware");

// === COOKING SESSION ROUTES ===

/**
 * Start a new cooking session
 * GET /api/recipes/:recipeId/cook/start
 */
router.get("/:recipeId/cook/start", protect, cookingController.startCookingSession);

/**
 * Get current cooking session
 * GET /api/recipes/:recipeId/cook/session/:sessionId
 */
router.get(
  "/:recipeId/cook/session/:sessionId",
  protect,
  cookingController.getCookingSession
);

/**
 * Mark a step as completed
 * PATCH /api/recipes/:recipeId/cook/session/:sessionId/step/:stepNumber
 */
router.patch(
  "/:recipeId/cook/session/:sessionId/step/:stepNumber",
  protect,
  cookingController.completeStep
);

/**
 * Pause cooking session
 * POST /api/recipes/:recipeId/cook/session/:sessionId/pause
 */
router.post(
  "/:recipeId/cook/session/:sessionId/pause",
  protect,
  cookingController.pauseCookingSession
);

/**
 * Resume cooking session
 * POST /api/recipes/:recipeId/cook/session/:sessionId/resume
 */
router.post(
  "/:recipeId/cook/session/:sessionId/resume",
  protect,
  cookingController.resumeCookingSession
);

/**
 * Complete cooking session
 * POST /api/recipes/:recipeId/cook/session/:sessionId/complete
 */
router.post(
  "/:recipeId/cook/session/:sessionId/complete",
  protect,
  cookingController.completeCookingSession
);

/**
 * Get recipe steps with details
 * GET /api/recipes/:recipeId/steps
 */
router.get("/:recipeId/steps", protect, cookingController.getRecipeSteps);

module.exports = router;
