/**
 * Recipe Service - Fetch and format recipe data for AI meal planning
 *
 * This service retrieves recipes from MongoDB and formats them
 * to match the AI service's expected recipe format.
 */

const { Recipe } = require("../../models/Recipe");
const { RecipeNutrition } = require("../../models/recipe_nutrion");
const { RecipeDietType } = require("../../models/recipe_diet_type");
const { RecipesIngredient } = require("../../models/recipes_ingredient");
const { Ingredient } = require("../../models/ingredients");
const { DietType } = require("../../models/diet_types");

/**
 * Fetch all published recipes with complete data for AI processing
 *
 * @param {Object} filters - Optional filters
 * @param {Array<string>} filters.dietTypes - Filter by diet types
 * @param {Array<string>} filters.excludeIngredients - Exclude recipes with these ingredients
 * @returns {Promise<Array>} Array of formatted recipes for AI
 */
async function getRecipesForAI(filters = {}) {
  try {
    // Build query for published recipes only
    const recipeQuery = { status: "published" };

    // Fetch all published recipes
    const recipes = await Recipe.find(recipeQuery).lean();

    if (!recipes || recipes.length === 0) {
      console.log("No published recipes found");
      return [];
    }

    // Fetch all related data in parallel
    const recipeIds = recipes.map((r) => r._id);
    console.log(`Querying related data for ${recipeIds.length} recipes`);
    console.log("Sample recipe ID:", recipeIds[0]);

    const [nutritionData, dietTypeData, ingredientData] = await Promise.all([
      // Get nutrition for all recipes
      RecipeNutrition.find({ recipeId: { $in: recipeIds } }).lean(),

      // Get diet types for all recipes
      RecipeDietType.find({ recipeId: { $in: recipeIds } })
        .populate("dietTypeId")
        .lean(),

      // Get ingredients for all recipes
      RecipesIngredient.find({ recipeId: { $in: recipeIds } })
        .populate("ingredientId")
        .lean(),
    ]);

    // Create lookup maps for efficient data access
    const nutritionMap = {};
    nutritionData.forEach((n) => {
      nutritionMap[n.recipeId.toString()] = n;
    });

    console.log(`Got ${dietTypeData.length} diet type associations`);
    if (dietTypeData.length > 0) {
      console.log(
        "Sample diet type data:",
        JSON.stringify(dietTypeData[0], null, 2),
      );
    }

    const dietTypeMap = {};
    dietTypeData.forEach((dt) => {
      const recipeId = dt.recipeId.toString();
      if (!dietTypeMap[recipeId]) {
        dietTypeMap[recipeId] = [];
      }
      if (dt.dietTypeId && dt.dietTypeId.name) {
        dietTypeMap[recipeId].push(
          dt.dietTypeId.name.toLowerCase().replace(/\s+/g, "_"),
        );
      } else {
        console.warn("Warning: dietTypeId not populated for record:", dt);
      }
    });

    const ingredientMap = {};
    ingredientData.forEach((ri) => {
      const recipeId = ri.recipeId.toString();
      if (!ingredientMap[recipeId]) {
        ingredientMap[recipeId] = [];
      }
      if (ri.ingredientId) {
        ingredientMap[recipeId].push(ri.ingredientId.name.toLowerCase());
      }
    });

    // Format recipes for AI service
    const formattedRecipes = recipes.map((recipe) => {
      const recipeId = recipe._id.toString();
      const nutrition = nutritionMap[recipeId] || {};
      const dietTypes = dietTypeMap[recipeId] || [];
      const ingredients = ingredientMap[recipeId] || [];

      // Calculate calories per serving
      const caloriesPerServing = nutrition.calories
        ? Math.round(nutrition.calories / (recipe.baseServings || 1))
        : 400; // Default fallback

      return {
        id: recipeId,
        name: recipe.name,
        description: recipe.description,
        image_url: recipe.imageUrl,
        cooking_time: recipe.cookingTime,
        base_servings: recipe.baseServings || 1,

        // Nutrition data (per serving)
        calories_per_serving: caloriesPerServing,
        protein_g: nutrition.protein
          ? Math.round(nutrition.protein / (recipe.baseServings || 1))
          : 0,
        carbs_g: nutrition.carbohydrates
          ? Math.round(nutrition.carbohydrates / (recipe.baseServings || 1))
          : 0,
        fat_g: nutrition.fat
          ? Math.round(nutrition.fat / (recipe.baseServings || 1))
          : 0,

        // Diet types (formatted for AI)
        diet_types: dietTypes,

        // Ingredients (for exclusion filtering)
        ingredients: ingredients,

        // Metadata (for scoring)
        rating: 4.0, // Default - can be computed from reviews
        review_count: 0, // Default - can be computed from reviews
      };
    });

    // Apply filters if provided
    let filteredRecipes = formattedRecipes;

    // Filter by diet types if specified
    if (filters.dietTypes && filters.dietTypes.length > 0) {
      console.log("Filtering by diet types:", filters.dietTypes);
      const dietTypesLower = filters.dietTypes.map((d) => d.toLowerCase());
      console.log("Diet types (lowercase):", dietTypesLower);
      console.log(
        "Sample recipe diet_types:",
        formattedRecipes[0] ? formattedRecipes[0].diet_types : "no recipes",
      );
      filteredRecipes = filteredRecipes.filter((recipe) =>
        recipe.diet_types.some((dt) => dietTypesLower.includes(dt)),
      );
      console.log(`After diet type filter: ${filteredRecipes.length} recipes`);
    }

    // Filter out recipes with excluded ingredients
    if (filters.excludeIngredients && filters.excludeIngredients.length > 0) {
      const excludedLower = filters.excludeIngredients.map((i) =>
        i.toLowerCase(),
      );
      filteredRecipes = filteredRecipes.filter((recipe) => {
        return !recipe.ingredients.some((ingredient) =>
          excludedLower.some((excluded) => ingredient.includes(excluded)),
        );
      });
    }

    console.log(
      `Formatted ${filteredRecipes.length} recipes for AI (out of ${recipes.length} total)`,
    );
    return filteredRecipes;
  } catch (error) {
    console.error("Error fetching recipes for AI:", error);
    throw new Error(`Failed to fetch recipes: ${error.message}`);
  }
}

/**
 * Get a single recipe formatted for AI
 *
 * @param {string} recipeId - Recipe ID
 * @returns {Promise<Object|null>} Formatted recipe or null
 */
async function getRecipeForAI(recipeId) {
  try {
    const recipes = await getRecipesForAI();
    return recipes.find((r) => r.id === recipeId) || null;
  } catch (error) {
    console.error(`Error fetching recipe ${recipeId} for AI:`, error);
    return null;
  }
}

/**
 * Get recipe count by diet type
 *
 * @returns {Promise<Object>} Count of recipes per diet type
 */
async function getRecipeCountByDietType() {
  try {
    const recipes = await getRecipesForAI();
    const counts = {};

    recipes.forEach((recipe) => {
      recipe.diet_types.forEach((dietType) => {
        counts[dietType] = (counts[dietType] || 0) + 1;
      });
    });

    return counts;
  } catch (error) {
    console.error("Error counting recipes by diet type:", error);
    return {};
  }
}

module.exports = {
  getRecipesForAI,
  getRecipeForAI,
  getRecipeCountByDietType,
};
