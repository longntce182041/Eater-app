const express = require("express");
const router = express.Router({ mergeParams: true });
const optimizationController = require("../controllers/meal.plan.optimization.controller");
const { protect } = require("../../middleware/authMiddleware");

// All routes require authentication
router.use(protect);

/**
 * GET /api/meal-plans/:planId/items/:itemId/suggestions
 * Get replacement suggestions for a specific meal
 */
router.get(
  "/:planId/items/:itemId/suggestions",
  optimizationController.getReplacementSuggestions,
);

/**
 * PATCH /api/meal-plans/:planId/items/:itemId/replace
 * Replace a meal with another recipe
 */
router.patch(
  "/:planId/items/:itemId/replace",
  optimizationController.replaceMealInPlan,
);

/**
 * POST /api/meal-plans/:planId/items/:itemId/rate
 * Rate a meal (1-5 stars)
 */
router.post("/:planId/items/:itemId/rate", optimizationController.rateMealItem);

/**
 * GET /api/meal-plans/:planId/optimization-suggestions
 * Get optimization suggestions for entire meal plan
 */
router.get(
  "/:planId/optimization-suggestions",
  optimizationController.getOptimizationSuggestions,
);

/**
 * POST /api/meal-plans/:planId/optimize
 * Optimize entire meal plan (replace low-rated meals, improve variety)
 */
router.post("/:planId/optimize", optimizationController.optimizeEntirePlan);

module.exports = router;
