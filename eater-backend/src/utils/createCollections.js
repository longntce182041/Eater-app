const User = require("../models/User");
const UserProfile = require("../models/User_Profile");
const Ingredient = require("../models/ingredients");
const Micronutrient = require("../models/micronutrients");
const Recipe = require("../models/Recipe");
const RecipeIngredient = require("../models/recipes_ingredient");
const RecipeStep = require("../models/recipes_step");
const RecipeReview = require("../models/recipes_review");
const RecipeNutrition = require("../models/recipe_nutrion");
const RecipeDietType = require("../models/recipe_diet_type");
const MealPlan = require("../models/meal_plans");
const MealPlanItem = require("../models/meal_plan_item");
const DietType = require("../models/diet_types");
const DietaryReference = require("../models/dietary_references");
const Nutritionist = require("../models/nutritionist");
const IngredientMicronutrient = require("../models/ingredient_micronutrient_values");

const createCollections = async () => {
  try {
    // Create all collections by accessing model.collection
    // Use syncIndexes() to safely handle existing indexes
    const models = [
      { name: "User", model: User },
      { name: "UserProfile", model: UserProfile },
      { name: "Ingredient", model: Ingredient },
      { name: "Micronutrient", model: Micronutrient },
      { name: "Recipe", model: Recipe },
      { name: "RecipeIngredient", model: RecipeIngredient },
      { name: "RecipeStep", model: RecipeStep },
      { name: "RecipeReview", model: RecipeReview },
      { name: "RecipeNutrition", model: RecipeNutrition },
      { name: "RecipeDietType", model: RecipeDietType },
      { name: "MealPlan", model: MealPlan },
      { name: "MealPlanItem", model: MealPlanItem },
      { name: "DietType", model: DietType },
      { name: "DietaryReference", model: DietaryReference },
      { name: "Nutritionist", model: Nutritionist },
      { name: "IngredientMicronutrient", model: IngredientMicronutrient },
    ];

    for (const { name, model } of models) {
      if (model && model.collection) {
        try {
          // syncIndexes() ensures indexes match schema without errors
          await model.syncIndexes();
          console.log(`✅ Collection "${name}" ready`);
        } catch (err) {
          console.warn(`⚠️  Issue with "${name}": ${err.message}`);
        }
      }
    }

    console.log("✅ All collections created/verified successfully!");
  } catch (error) {
    console.error("❌ Error creating collections:", error.message);
  }
};

module.exports = { createCollections };
