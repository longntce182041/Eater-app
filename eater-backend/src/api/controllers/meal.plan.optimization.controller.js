const optimizationService = require("../services/meal.plan.optimization.service");

/**
 * Get replacement suggestions for a meal
 */
async function getReplacementSuggestions(req, res) {
  try {
    const { planId, itemId } = req.params;

    if (!planId || !itemId) {
      return res.status(400).json({
        success: false,
        message: "planId and itemId required",
      });
    }

    const suggestions = await optimizationService.findReplacementRecipes(
      itemId,
      req.user._id,
    );

    res.status(200).json({
      success: true,
      data: suggestions,
      count: suggestions.length,
    });
  } catch (error) {
    console.error("Error getting replacement suggestions:", error);
    res.status(500).json({
      success: false,
      message: "Failed to get suggestions",
      error: error.message,
    });
  }
}

/**
 * Replace a meal in meal plan
 */
async function replaceMealInPlan(req, res) {
  try {
    const { planId, itemId } = req.params;
    const { newRecipeId, reason } = req.body;

    if (!planId || !itemId || !newRecipeId) {
      return res.status(400).json({
        success: false,
        message: "planId, itemId, and newRecipeId required",
      });
    }

    const updatedItem = await optimizationService.replaceMeal(
      planId,
      itemId,
      newRecipeId,
      reason,
    );

    res.status(200).json({
      success: true,
      message: "✓ Meal replaced successfully",
      data: updatedItem,
    });
  } catch (error) {
    console.error("Error replacing meal:", error);
    res.status(500).json({
      success: false,
      message: "Failed to replace meal",
      error: error.message,
    });
  }
}

/**
 * Get optimization suggestions for meal plan
 */
async function getOptimizationSuggestions(req, res) {
  try {
    const { planId } = req.params;

    if (!planId) {
      return res.status(400).json({
        success: false,
        message: "planId required",
      });
    }

    const suggestions = await optimizationService.getOptimizationSuggestions(
      planId,
      req.user._id,
    );

    res.status(200).json({
      success: true,
      data: suggestions,
    });
  } catch (error) {
    console.error("Error getting optimization suggestions:", error);
    res.status(500).json({
      success: false,
      message: "Failed to get optimization suggestions",
      error: error.message,
    });
  }
}

/**
 * Optimize entire meal plan
 */
async function optimizeEntirePlan(req, res) {
  try {
    const { planId } = req.params;

    if (!planId) {
      return res.status(400).json({
        success: false,
        message: "planId required",
      });
    }

    const result = await optimizationService.optimizeMealPlan(
      planId,
      req.user._id,
    );

    res.status(200).json({
      success: true,
      data: result,
    });
  } catch (error) {
    console.error("Error optimizing meal plan:", error);
    res.status(500).json({
      success: false,
      message: "Failed to optimize meal plan",
      error: error.message,
    });
  }
}

/**
 * Rate a meal
 */
async function rateMealItem(req, res) {
  try {
    const { planId, itemId } = req.params;
    const { rating } = req.body;

    if (!itemId || !rating) {
      return res.status(400).json({
        success: false,
        message: "itemId and rating required",
      });
    }

    const ratedItem = await optimizationService.rateMeal(itemId, rating);

    res.status(200).json({
      success: true,
      message: `✓ Meal rated ${rating}/5`,
      data: ratedItem,
    });
  } catch (error) {
    console.error("Error rating meal:", error);
    res.status(500).json({
      success: false,
      message: "Failed to rate meal",
      error: error.message,
    });
  }
}

module.exports = {
  getReplacementSuggestions,
  replaceMealInPlan,
  getOptimizationSuggestions,
  optimizeEntirePlan,
  rateMealItem,
};
