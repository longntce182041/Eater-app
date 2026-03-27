// Use Gemini client for meal plan generation
const { generateMealPlanWithGemini } = require("../google/geminiClient");

/**
 * Generate and return a meal plan using Gemini
 * @param {Object} userContext - { userProfile, recipeDatabase, days }
 * @returns {Promise<Object>} Meal plan JSON
 */
async function requestAIMealPlan({ userProfile, recipeDatabase, days }) {
  // Only Gemini, no Python/aiClient
  return await generateMealPlanWithGemini({
    userProfile,
    recipeDatabase,
    days,
  });
}

module.exports = {
  requestAIMealPlan,
};
