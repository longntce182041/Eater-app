/**
 * Example: Generate & Save AI Meal Plan to Database
 *
 * This example demonstrates the complete flow:
 * 1. Analyze user profile
 * 2. Fetch recipes from MongoDB
 * 3. Generate personalized meal plan with AI
 * 4. Save meal plan to database
 */

const mongoose = require("mongoose");
const recipeService = require("./src/api/services/recipe.service");
const aiClient = require("./src/integrations/ai/aiClient");
const aiService = require("./src/api/services/ai.services");

// MongoDB connection
const MONGODB_URI =
  process.env.MONGODB_URI ||
  "mongodb://127.0.0.1:27017/ai_healthy_meal_planner";

/**
 * Complete example: Generate and save meal plan
 */
async function generateAndSaveMealPlan() {
  console.log("\n╔══════════════════════════════════════════════════════════╗");
  console.log("║  Generate & Save AI Meal Plan to Database              ║");
  console.log("╚══════════════════════════════════════════════════════════╝\n");

  try {
    // Connect to MongoDB
    if (mongoose.connection.readyState === 0) {
      console.log("⚠️  MongoDB is not connected. Connecting...\n");
      await mongoose.connect(MONGODB_URI);
      console.log(
        "MongoDB connected:",
        mongoose.connection.host + "/" + mongoose.connection.name,
      );
    }

    // STEP 1: Analyze User Profile
    console.log("\n📊 Step 1: Analyzing user profile...");
    const userId = "507f1f77bcf86cd799439011"; // Example user ID (must be valid ObjectId)

    const profileData = {
      user_id: userId,
      age: 30,
      gender: "female",
      height_cm: 165,
      weight_kg: 70,
      goal_weight_kg: 65,
      health_goals: "weight_loss",
      activity_level: "moderate",
    };

    const profileResponse = await aiClient.analyzeUserProfile(profileData);
    console.log("✅ Profile analyzed successfully!");
    console.log(`   BMR: ${profileResponse.health_metrics.bmr} cal`);
    console.log(`   TDEE: ${profileResponse.health_metrics.tdee} cal`);
    console.log(`   BMI: ${profileResponse.bmi}`);
    console.log("   Full response:", JSON.stringify(profileResponse, null, 2));

    const body_profile = {
      age: profileResponse.age || profileData.age,
      gender: profileResponse.gender || profileData.gender,
      bmi: profileResponse.bmi,
      bmr: profileResponse.health_metrics.bmr,
      tdee: profileResponse.health_metrics.tdee,
      activity_level:
        profileResponse.activity_level || profileData.activity_level,
    };

    // STEP 2: Fetch recipes from MongoDB
    console.log("\n🗄️  Step 2: Fetching recipes from MongoDB...");
    const recipes = await recipeService.getRecipesForAI({
      dietTypes: ["vegetarian", "balanced"],
      limit: 20,
    });
    console.log(`✅ Fetched ${recipes.length} recipes from database`);

    if (recipes.length === 0) {
      console.log(
        "⚠️  No recipes found. Please run: node scripts/seed-recipes.js",
      );
      return;
    }

    // STEP 3: Generate meal plan with AI
    console.log("\n🍽️  Step 3: Generating personalized meal plan with AI...");
    const pipelineParams = {
      user_id: userId,
      body_profile: body_profile,
      diet_types: ["vegetarian"],
      allergies: [],
      disliked_ingredients: [],
      health_goal: "weight_loss",
      days: 1, // Generate for 1 day
      recipe_database: recipes,
    };

    const mealPlanResult =
      await aiClient.generateMealPlanPipeline(pipelineParams);
    console.log("✅ Meal plan generated successfully!");

    const mealPlan = mealPlanResult.meal_plan || mealPlanResult;
    const meals = mealPlan.meals || [];

    if (meals.length === 0) {
      console.error("⚠️  No meals found in meal plan");
      return;
    }

    const targetCal =
      mealPlanResult.goal_profile?.target_calories || mealPlan.daily_calories;
    console.log(`   Target Calories: ${targetCal.toFixed(2)} cal/day`);
    console.log(`   Meals Generated: ${meals.length}`);

    // Display generated meal plan
    console.log("\n🍳 Generated Meal Plan:");
    meals.forEach((meal, index) => {
      console.log(
        `   ${index + 1}. ${meal.meal_type.toUpperCase()}: ${meal.recipe_name}`,
      );
      console.log(
        `      Calories: ${(meal.calories || meal.estimated_calories).toFixed(0)} | Servings: ${meal.servings.toFixed(2)}`,
      );
      console.log(
        `      Macros: P=${meal.protein_g}g | C=${meal.carbs_g}g | F=${meal.fat_g}g`,
      );
    });

    // STEP 4: Save meal plan to database
    console.log("\n💾 Step 4: Saving meal plan to database...");
    const saveResult = await aiService.saveAIMealPlanToDatabase(
      userId,
      mealPlanResult,
      {
        dietTypes: ["vegetarian"],
        healthGoal: "weight_loss",
        startDate: new Date(),
      },
    );

    console.log("✅ Meal plan saved successfully!");
    console.log(`   Meal Plan ID: ${saveResult.mealPlan._id}`);
    console.log(`   Items Saved: ${saveResult.items.length}`);
    console.log(`   Days: ${saveResult.summary.days}`);
    console.log(
      `   Avg Calories/Day: ${saveResult.summary.avgCaloriesPerDay.toFixed(0)}`,
    );

    // Display saved items
    console.log("\n📋 Saved Meal Plan Items:");
    saveResult.items.forEach((item, index) => {
      console.log(`   ${index + 1}. ${item.mealType.toUpperCase()}`);
      console.log(`      Recipe ID: ${item.recipeId}`);
      console.log(`      Servings: ${item.servings.toFixed(2)}`);
      console.log(`      Calories: ${item.calories}`);
      console.log(
        `      P: ${item.protein}g | C: ${item.carbohydrates}g | F: ${item.fat}g`,
      );
    });

    console.log(
      "\n╔══════════════════════════════════════════════════════════╗",
    );
    console.log("║  ✅ Meal Plan Generated & Saved Successfully!          ║");
    console.log(
      "╚══════════════════════════════════════════════════════════╝\n",
    );

    return saveResult;
  } catch (error) {
    console.error("\n❌ Error:", error.message);
    if (error.response?.data) {
      console.error(
        "AI Service Error Details:",
        JSON.stringify(error.response.data, null, 2),
      );
    }
    throw error;
  }
}

/**
 * Retrieve saved meal plans for a user
 */
async function getUserSavedMealPlans(userId) {
  console.log(`\n📋 Retrieving saved meal plans for user: ${userId}`);

  try {
    const mealPlans = await aiService.getUserMealPlans(userId, 5);

    console.log(`✅ Found ${mealPlans.length} meal plans`);

    mealPlans.forEach((plan, index) => {
      console.log(`\n${index + 1}. Meal Plan ID: ${plan._id}`);
      console.log(`   Date: ${plan.date}`);
      console.log(`   Days: ${plan.days}`);
      console.log(`   Target Calories: ${plan.targetCalories}`);
      console.log(`   Diet Types: ${plan.dietTypes?.join(", ") || "N/A"}`);
      console.log(`   Status: ${plan.status}`);
      console.log(`   AI Generated: ${plan.aiGenerated ? "Yes" : "No"}`);
    });

    return mealPlans;
  } catch (error) {
    console.error("❌ Error retrieving meal plans:", error.message);
    throw error;
  }
}

// Run the example
if (require.main === module) {
  generateAndSaveMealPlan()
    .then(async (result) => {
      // Retrieve saved meal plans
      await getUserSavedMealPlans(result.mealPlan.userId);

      console.log("✅ Example completed successfully");
      process.exit(0);
    })
    .catch((error) => {
      console.error("❌ Example failed:", error);
      process.exit(1);
    })
    .finally(() => {
      mongoose.connection.close();
    });
}

module.exports = {
  generateAndSaveMealPlan,
  getUserSavedMealPlans,
};
