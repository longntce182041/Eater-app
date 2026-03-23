const mongoose = require('mongoose');
const { Recipe } = require('../../models/Recipe');
const { RecipesIngredient } = require('../../models/recipes_ingredient');
const { RecipesStep } = require('../../models/recipes_step');
const { RecipeNutrition } = require('../../models/recipe_nutrion');
const { RecipeMicronutrientValues } = require('../../models/recipe_micronutrient_values');
const { IngredientMicronutrientValues } = require('../../models/ingredient_micronutrient_values');

class ViewRecipeDetailService {
  // Get full recipe details for meal plan view (with all nested data including ingredient micronutrients)
  async getFullRecipeDetails(recipeId) {
    try {
      console.log(`[ViewRecipeDetailService] Fetching recipe details for ID: ${recipeId}`);
      
      const recipe = await Recipe.findById(recipeId);
      if (!recipe) {
        throw new Error("Recipe not found");
      }

      // Fetch ingredients (populated)
      const ingredients = await RecipesIngredient.find({ recipeId }).populate('ingredientId');
      
      // Fetch micronutrients for each ingredient
      const ingredientsWithMicronutrients = await Promise.all(
        ingredients.map(async (ing) => {
          const micronutrients = await IngredientMicronutrientValues.find({
            ingredientId: ing.ingredientId._id
          }).populate('micronutrientId');
          
          return {
            ...ing.toObject(),
            micronutrients
          };
        })
      );

      // Fetch other recipe data
      const [steps, nutrition, recipeMicronutrients] = await Promise.all([
        RecipesStep.find({ recipeId }).sort({ stepNumber: 1 }),
        RecipeNutrition.findOne({ recipeId }),
        RecipeMicronutrientValues.find({ recipeId }).populate('micronutrientId')
      ]);

      console.log(`[ViewRecipeDetailService] Recipe fetched: ${recipe.name}, Ingredients: ${ingredientsWithMicronutrients.length}, Steps: ${steps.length}`);

      return {
        ...recipe.toObject(),
        ingredients: ingredientsWithMicronutrients,
        steps,
        nutrition,
        micronutrients: recipeMicronutrients
      };
    } catch (error) {
      console.error(`[ViewRecipeDetailService] Error fetching recipe: ${error.message}`);
      throw error;
    }
  }

  // Get recipe with basic info only
  async getRecipeBasicInfo(recipeId) {
    try {
      const recipe = await Recipe.findById(recipeId);
      if (!recipe) {
        throw new Error("Recipe not found");
      }
      return recipe;
    } catch (error) {
      throw error;
    }
  }
}

module.exports = new ViewRecipeDetailService();
