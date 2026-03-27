// Gemini Client for Meal Plan Generation
// Uses @google/generative-ai
const { GoogleGenerativeAI } = require("@google/generative-ai");
const API_KEY = process.env.GOOGLE_API_KEY;

if (!API_KEY) {
  throw new Error("GOOGLE_API_KEY is not set in environment variables");
}

const genAI = new GoogleGenerativeAI(API_KEY);
const MODEL = "gemini-1.5-flash";

/**
 * Calls Gemini to generate a meal plan JSON for the user
 * @param {Object} userProfile - User profile JSON
 * @param {Array} recipeDatabase - Array of recipe objects
 * @param {number} days - Number of days for the meal plan
 * @returns {Promise<Object>} Parsed meal plan JSON
 */
async function generateMealPlanWithGemini({
  userProfile,
  recipeDatabase,
  days,
}) {
  const prompt = `You are an expert meal planning assistant.\nGiven the following user profile (as JSON) and a list of available recipes (as JSON), generate a meal plan for ${days} days.\nOutput only valid JSON in this schema (no markdown):\n\n{\n  "mealPlan": [\n    {\n      "dayIndex": 1,\n      "meals": [\n        {\n          "mealType": "breakfast",\n          "recipeId": "6474b0e980c29999c7e8704b",\n          "servings": 1,\n          "calories": 345,\n          "protein": 24,\n          "carbohydrates": 44,\n          "fat": 9\n        },\n        ...\n      ]\n    },\n    ...\n  ]\n}\n\nUser Profile:\n${JSON.stringify(userProfile)}\n\nAvailable Recipes:\n${JSON.stringify(recipeDatabase)}\n`;

  const model = genAI.getGenerativeModel({ model: MODEL });
  const result = await model.generateContent({
    contents: [{ role: "user", parts: [{ text: prompt }] }],
  });
  const text =
    result?.response?.candidates?.[0]?.content?.parts?.[0]?.text ||
    result?.response?.text ||
    "";
  const json = robustParseGeminiJSON(text);
  validateMealPlanSchema(json);
  return json;
}

// Robustly parse Gemini output for JSON
function robustParseGeminiJSON(text) {
  // Remove code fencing, markdown, and extract JSON
  const jsonMatch = text.match(/\{[\s\S]*\}/);
  if (!jsonMatch) throw new Error("Gemini did not return valid JSON");
  try {
    return JSON.parse(jsonMatch[0]);
  } catch (e) {
    throw new Error("Failed to parse Gemini JSON: " + e.message);
  }
}

// Validate meal plan schema
function validateMealPlanSchema(obj) {
  if (!obj || !Array.isArray(obj.mealPlan))
    throw new Error("Missing mealPlan array");
  for (const day of obj.mealPlan) {
    if (typeof day.dayIndex !== "number" || !Array.isArray(day.meals))
      throw new Error("Invalid day structure");
    for (const meal of day.meals) {
      if (!["breakfast", "lunch", "dinner", "snack"].includes(meal.mealType))
        throw new Error("Invalid mealType: " + meal.mealType);
      if (!meal.recipeId) throw new Error("Missing recipeId");
      if (typeof meal.servings !== "number")
        throw new Error("Missing servings");
      if (typeof meal.calories !== "number")
        throw new Error("Missing calories");
      // Optional: protein, carbohydrates, fat
    }
  }
}

module.exports = {
  generateMealPlanWithGemini,
};
