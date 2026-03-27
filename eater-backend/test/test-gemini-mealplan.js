// Test script for Gemini meal plan integration
require("dotenv").config({ path: "../.env" });
const {
  generateMealPlanWithGemini,
} = require("../src/integrations/google/geminiClient");

(async () => {
  // Mock user profile
  const userProfile = {
    age: 28,
    gender: "female",
    height: 165,
    weight: 60,
    goalWeight: 55,
    healthGoals: ["weight_loss"],
    dietTypes: ["vegetarian"],
    allergens: ["peanut"],
    restrictions: ["gluten"],
    excludedIngredients: ["beef"],
    healthMetrics: { bmi: 22, bmr: 1400, tdee: 1800 },
  };

  // Mock recipe database (minimal example)
  const recipeDatabase = [
    {
      id: "6474b0e980c29999c7e8704b",
      name: "Oatmeal with Berries",
      calories_per_serving: 350,
      protein_g: 10,
      carbs_g: 60,
      fat_g: 5,
      diet_types: ["vegetarian"],
      ingredients: ["oats", "berries", "milk"],
    },
    {
      id: "6474b0e980c29999c7e8704c",
      name: "Quinoa Salad",
      calories_per_serving: 400,
      protein_g: 12,
      carbs_g: 55,
      fat_g: 8,
      diet_types: ["vegetarian", "gluten_free"],
      ingredients: ["quinoa", "tomato", "cucumber"],
    },
  ];

  try {
    const days = 3;
    const result = await generateMealPlanWithGemini({
      userProfile,
      recipeDatabase,
      days,
    });
    console.log("Gemini meal plan result:", JSON.stringify(result, null, 2));
  } catch (err) {
    console.error("Gemini meal plan error:", err);
  }
})();
