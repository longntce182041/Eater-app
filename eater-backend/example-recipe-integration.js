/**
 * Complete Integration Example: MongoDB Recipes → AI Meal Planning
 *
 * This example demonstrates how to:
 * 1. Fetch recipes from MongoDB
 * 2. Analyze user profile
 * 3. Generate personalized meal plan with real recipe data
 */

const recipeService = require("./src/api/services/recipe.service");
const aiClient = require("./src/integrations/ai/aiClient");

/**
 * Example 1: Generate meal plan with MongoDB recipes
 */
async function generateMealPlanWithRealRecipes() {
  console.log("\n=== Generate Meal Plan with Real MongoDB Recipes ===\n");

  try {
    // STEP 1: Analyze User Profile (get body_profile)
    console.log("📊 Step 1: Analyzing user profile...");
    const profileData = {
      user_id: "user_real_recipes_001",
      age: 28,
      gender: "female",
      height_cm: 165, // Changed from 'height'
      weight_kg: 68, // Changed from 'weight'
      goal_weight_kg: 65, // Added
      health_goals: "weight_loss", // Added
      activity_level: "moderate", // Changed from 'medium' to 'moderate'
    };

    const profileResponse = await aiClient.analyzeUserProfile(profileData);
    console.log("✅ Profile analyzed successfully!");
    console.log(`   BMR: ${profileResponse.health_metrics.bmr} cal`);
    console.log(`   TDEE: ${profileResponse.health_metrics.tdee} cal`);
    console.log(`   BMI: ${profileResponse.bmi}`);

    const body_profile = {
      age: profileResponse.age || profileData.age,
      gender: profileResponse.gender || profileData.gender,
      bmi: profileResponse.bmi,
      bmr: profileResponse.health_metrics.bmr,
      tdee: profileResponse.health_metrics.tdee,
      activity_level: profileResponse.activity_level,
    };

    // STEP 2: Fetch real recipes from MongoDB
    console.log("\n🗄️  Step 2: Fetching recipes from MongoDB...");
    const recipes = await recipeService.getRecipesForAI();
    console.log(`✅ Fetched ${recipes.length} recipes from database`);

    if (recipes.length === 0) {
      console.log(
        "⚠️  No recipes found in database. Please add recipes first.",
      );
      return;
    }

    // Show sample recipe data
    if (recipes.length > 0) {
      const sample = recipes[0];
      console.log("\n📋 Sample Recipe:");
      console.log(`   Name: ${sample.name}`);
      console.log(`   Calories: ${sample.calories_per_serving} per serving`);
      console.log(`   Diet Types: ${sample.diet_types.join(", ") || "none"}`);
      console.log(
        `   Ingredients: ${sample.ingredients.slice(0, 3).join(", ")}...`,
      );
    }

    // STEP 3: Generate meal plan with real recipes
    console.log("\n🍽️  Step 3: Generating personalized meal plan...");
    const pipelineRequest = {
      user_id: "user_real_recipes_001",
      diet_types: ["vegetarian"], // Adjust based on your recipes
      allergies: ["peanuts"],
      disliked_ingredients: [],
      health_goal: "weight_loss",
      target_weight: 65,
      timeline_weeks: 12,
      body_profile: body_profile,
      recipe_database: recipes, // ← Pass real recipes here!
      days: 1,
    };

    const mealPlan = await aiClient.generateMealPlanPipeline(pipelineRequest);

    console.log("\n✅ Meal plan generated successfully!");
    console.log("\n📊 Results:");
    console.log(`   User ID: ${mealPlan.user_id}`);
    console.log(
      `   Diet Types: ${mealPlan.diet_constraints.diet_types.join(", ") || "none"}`,
    );
    console.log(
      `   Excluded: ${mealPlan.diet_constraints.excluded_ingredients.slice(0, 5).join(", ")}`,
    );
    console.log(
      `   Target Calories: ${mealPlan.goal_profile.target_calories} cal`,
    );
    console.log(
      `   Actual Calories: ${Math.round(mealPlan.meal_plan.daily_calories)} cal`,
    );
    console.log(`   Meals Generated: ${mealPlan.meal_plan.meals.length}`);

    console.log("\n🍳 Daily Meal Plan:");
    mealPlan.meal_plan.meals.forEach((meal, index) => {
      console.log(
        `   ${index + 1}. ${meal.meal_type.toUpperCase()}: ${meal.recipe_name}`,
      );
      console.log(`      Recipe ID: ${meal.recipe_id} (from MongoDB)`);
      console.log(
        `      Servings: ${meal.servings} | Calories: ${Math.round(meal.estimated_calories)}`,
      );
      console.log(
        `      Macros: P=${meal.protein_g}g | C=${meal.carbs_g}g | F=${meal.fat_g}g`,
      );
    });

    console.log("\n📈 Daily Totals:");
    console.log(
      `   Protein: ${Math.round(mealPlan.meal_plan.total_protein_g)}g`,
    );
    console.log(`   Carbs: ${Math.round(mealPlan.meal_plan.total_carbs_g)}g`);
    console.log(`   Fat: ${Math.round(mealPlan.meal_plan.total_fat_g)}g`);

    console.log("\n🎯 Meta Information:");
    console.log(
      `   Pipeline Version: ${mealPlan.pipeline_metadata.pipeline_version}`,
    );
    console.log(
      `   Steps Executed: ${mealPlan.pipeline_metadata.steps_executed}`,
    );
    console.log(
      `   Candidate Recipes: ${mealPlan.pipeline_metadata.generation_metadata.candidate_recipes_count}`,
    );
    console.log(
      `   Calorie Match: ${mealPlan.pipeline_metadata.generation_metadata.calorie_match_percentage.toFixed(1)}%`,
    );

    return mealPlan;
  } catch (error) {
    console.error("❌ Error:", error.message);
    if (error.response?.data) {
      console.error(
        "   Details:",
        JSON.stringify(error.response.data, null, 2),
      );
    }
    throw error;
  }
}

/**
 * Example 2: Filter recipes before sending to AI
 */
async function generateMealPlanWithFilteredRecipes() {
  console.log("\n=== Generate Meal Plan with Filtered Recipes ===\n");

  try {
    const profileData = {
      user_id: "user_filtered_recipes",
      age: 32,
      gender: "male",
      height_cm: 180, // Changed from 'height'
      weight_kg: 85, // Changed from 'weight'
      goal_weight_kg: 80, // Added
      health_goals: "muscle_gain", // Added
      activity_level: "very_active", // Changed from 'high' to 'very_active'
    };

    // Analyze profile
    const profileResponse = await aiClient.analyzeUserProfile(profileData);
    const body_profile = {
      age: profileResponse.age || profileData.age,
      gender: profileResponse.gender || profileData.gender,
      bmi: profileResponse.bmi,
      bmr: profileResponse.health_metrics.bmr,
      tdee: profileResponse.health_metrics.tdee,
      activity_level: profileResponse.activity_level,
    };

    // Fetch recipes with pre-filtering
    console.log("🗄️  Fetching filtered recipes...");
    const recipes = await recipeService.getRecipesForAI({
      dietTypes: ["keto", "low_carb"], // Only keto/low-carb recipes
      excludeIngredients: ["gluten", "wheat"], // Exclude gluten
    });

    console.log(`✅ Fetched ${recipes.length} filtered recipes`);

    if (recipes.length === 0) {
      console.log("⚠️  No matching recipes found. Try adjusting filters.");
      return;
    }

    // Generate meal plan
    const mealPlan = await aiClient.generateMealPlanPipeline({
      user_id: "user_filtered_recipes",
      diet_types: ["keto"],
      allergies: [],
      disliked_ingredients: [],
      health_goal: "muscle_gain",
      body_profile: body_profile,
      recipe_database: recipes,
      days: 1,
    });

    console.log("✅ Meal plan generated with filtered recipes!");
    console.log(
      `   ${mealPlan.meal_plan.meals.length} meals from ${recipes.length} available recipes`,
    );

    return mealPlan;
  } catch (error) {
    console.error("❌ Error:", error.message);
    throw error;
  }
}

/**
 * Example 3: Check recipe availability by diet type
 */
async function checkRecipeAvailability() {
  console.log("\n=== Recipe Availability Check ===\n");

  try {
    const counts = await recipeService.getRecipeCountByDietType();

    console.log("📊 Recipe Count by Diet Type:");
    Object.entries(counts).forEach(([dietType, count]) => {
      console.log(`   ${dietType}: ${count} recipes`);
    });

    console.log("\n💡 Tip: Add more recipes of underrepresented diet types");
  } catch (error) {
    console.error("❌ Error checking availability:", error.message);
  }
}

/**
 * Main execution
 */
async function main() {
  console.log("╔══════════════════════════════════════════════════════════╗");
  console.log("║  MongoDB Recipes → AI Meal Planning Integration        ║");
  console.log("╚══════════════════════════════════════════════════════════╝");

  // Check MongoDB connection
  const mongoose = require("mongoose");
  if (mongoose.connection.readyState !== 1) {
    console.log("⚠️  MongoDB is not connected. Connecting...");
    await require("./src/config/mongo");
  }

  // Run examples
  await checkRecipeAvailability();
  await generateMealPlanWithRealRecipes();
  // await generateMealPlanWithFilteredRecipes();

  console.log("\n╔══════════════════════════════════════════════════════════╗");
  console.log("║  Integration Complete!                                  ║");
  console.log("╚══════════════════════════════════════════════════════════╝");
}

// Run if executed directly
if (require.main === module) {
  main()
    .then(() => {
      console.log("\n✅ All examples completed successfully");
      process.exit(0);
    })
    .catch((error) => {
      console.error("\n❌ Examples failed:", error);
      process.exit(1);
    });
}

module.exports = {
  generateMealPlanWithRealRecipes,
  generateMealPlanWithFilteredRecipes,
  checkRecipeAvailability,
};
