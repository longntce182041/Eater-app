/**
 * Example usage of AI Service
 * This file demonstrates how to use the AI service in your application
 */

const aiService = require("./src/api/services/ai.services");

/**
 * Example 1: Generate meal plan for a user
 */
async function exampleGenerateMealPlan() {
  console.log("=== Example 1: Generate Meal Plan ===");

  try {
    const userId = "507f1f77bcf86cd799439011"; // Replace with actual user ID
    const options = {
      days: 7,
      useML: false,
    };

    console.log(`Generating meal plan for user: ${userId}`);
    const result = await aiService.generateAndSaveMealPlan(userId, options);

    if (result.success) {
      console.log("✅ Meal plan generated successfully!");
      console.log("Meal Plan ID:", result.mealPlan._id);
      console.log("Days:", result.mealPlan.days);
    } else {
      console.log("❌ Failed to generate meal plan");
      console.log("Error:", result.error);
    }
  } catch (error) {
    console.error("Error in example:", error.message);
  }
}

/**
 * Example 2: Get user data prepared for AI
 */
async function exampleGetUserData() {
  console.log("\n=== Example 2: Get User Data for AI ===");

  try {
    const userId = "507f1f77bcf86cd799439011"; // Replace with actual user ID

    const userData = await aiService.prepareUserDataForAI(userId);

    console.log("✅ User data retrieved successfully!");
    console.log("User Profile:", JSON.stringify(userData.profile, null, 2));
    console.log(
      "Dietary Preferences:",
      JSON.stringify(userData.dietaryPreferences, null, 2),
    );
    console.log(
      "Health Metrics:",
      JSON.stringify(userData.healthMetrics, null, 2),
    );
  } catch (error) {
    console.error("Error in example:", error.message);
  }
}

/**
 * Example 3: Get user's meal plans
 */
async function exampleGetMealPlans() {
  console.log("\n=== Example 3: Get User Meal Plans ===");

  try {
    const userId = "507f1f77bcf86cd799439011"; // Replace with actual user ID
    const limit = 5;

    const mealPlans = await aiService.getUserMealPlans(userId, limit);

    console.log(`✅ Retrieved ${mealPlans.length} meal plans`);
    mealPlans.forEach((plan, index) => {
      console.log(`\nPlan ${index + 1}:`);
      console.log("  ID:", plan._id);
      console.log("  Created:", plan.createdAt);
      console.log("  Days:", plan.days);
    });
  } catch (error) {
    console.error("Error in example:", error.message);
  }
}

/**
 * Example 4: Get recommended recipes
 */
async function exampleGetRecommendedRecipes() {
  console.log("\n=== Example 4: Get Recommended Recipes ===");

  try {
    const userId = "507f1f77bcf86cd799439011"; // Replace with actual user ID
    const limit = 5;

    const recipes = await aiService.getRecommendedRecipes(userId, limit);

    console.log(`✅ Retrieved ${recipes.length} recommended recipes`);
    recipes.forEach((recipe, index) => {
      console.log(`\nRecipe ${index + 1}:`);
      console.log("  Name:", recipe.name);
      console.log("  Description:", recipe.description);
      console.log("  Rating:", recipe.rating || "N/A");
    });
  } catch (error) {
    console.error("Error in example:", error.message);
  }
}

/**
 * Example 5: Direct AI service call
 */
async function exampleDirectAICall() {
  console.log("\n=== Example 5: Direct AI Service Call ===");

  try {
    const userId = "507f1f77bcf86cd799439011"; // Replace with actual user ID

    console.log("Calling AI service directly...");
    const aiResponse = await aiService.generateAIMealPlan(userId, 7, false);

    console.log("✅ AI service responded successfully!");
    console.log("Response:", JSON.stringify(aiResponse, null, 2));
  } catch (error) {
    console.error("Error in example:", error.message);
  }
}

/**
 * Example 6: Complete workflow with error handling
 */
async function exampleCompleteWorkflow() {
  console.log("\n=== Example 6: Complete Workflow ===");

  const userId = "507f1f77bcf86cd799439011"; // Replace with actual user ID

  try {
    // Step 1: Get user data
    console.log("Step 1: Fetching user data...");
    const userData = await aiService.prepareUserDataForAI(userId);
    console.log("✅ User data fetched");

    // Step 2: Generate meal plan
    console.log("\nStep 2: Generating meal plan...");
    const result = await aiService.generateAndSaveMealPlan(userId, {
      days: 7,
      useML: false,
    });

    if (!result.success) {
      throw new Error(result.error);
    }
    console.log("✅ Meal plan generated and saved");

    // Step 3: Retrieve saved meal plans
    console.log("\nStep 3: Retrieving saved meal plans...");
    const mealPlans = await aiService.getUserMealPlans(userId, 5);
    console.log(`✅ Found ${mealPlans.length} meal plans`);

    // Step 4: Get recommended recipes
    console.log("\nStep 4: Getting recommended recipes...");
    const recipes = await aiService.getRecommendedRecipes(userId, 5);
    console.log(`✅ Found ${recipes.length} recommended recipes`);

    console.log("\n🎉 Complete workflow executed successfully!");
  } catch (error) {
    console.error("❌ Workflow failed:", error.message);
  }
}

/**
 * Example 7: Complete Integration - User Profile Analysis + Meal Plan Pipeline
 * This demonstrates the proper integration pattern between upstream and downstream functions
 */
async function exampleMealPlanPipeline() {
  console.log(
    "\n=== Example 7: User Profile → Meal Plan Pipeline Integration ===",
  );

  try {
    const aiClient = require("./src/integrations/ai/aiClient");

    // STEP 1: Analyze User Profile (UPSTREAM FUNCTION)
    console.log("\n📊 Step 1: Analyzing user profile...");
    const profileData = {
      age: 30,
      gender: "female",
      height: 165,
      weight: 70,
      activityLevel: "medium",
    };

    const profileResponse = await aiClient.analyzeUserProfile(profileData);
    console.log("✅ Profile analyzed successfully!");
    console.log(
      "Body Profile:",
      JSON.stringify(profileResponse.health_metrics, null, 2),
    );

    // Extract body_profile from upstream function
    const body_profile = {
      age: profileResponse.health_metrics.age,
      gender: profileResponse.health_metrics.gender,
      bmi: profileResponse.health_metrics.bmi,
      bmr: profileResponse.health_metrics.bmr,
      tdee: profileResponse.health_metrics.tdee,
      activity_level: profileData.activityLevel,
    };

    // STEP 2: Generate Meal Plan using body_profile (DOWNSTREAM FUNCTION)
    console.log("\n🍽️  Step 2: Generating personalized meal plan...");
    const pipelineRequest = {
      user_id: "user_12345",
      diet_types: ["vegetarian", "gluten_free"],
      allergies: ["peanuts"],
      disliked_ingredients: ["mushrooms"],
      health_goal: "weight_loss",
      target_weight: 65,
      timeline_weeks: 12,
      body_profile: body_profile, // ← Using body_profile from upstream
      days: 1,
    };

    // Call the new AI pipeline
    const axios = require("axios");
    const AI_SERVICE_URL =
      process.env.AI_SERVICE_URL || "http://localhost:8000";

    const mealPlanResponse = await axios.post(
      `${AI_SERVICE_URL}/api/v1/pipeline/complete-pipeline`,
      pipelineRequest,
      {
        headers: { "Content-Type": "application/json" },
      },
    );

    console.log("✅ Meal plan generated successfully!");
    console.log("\n📋 Pipeline Results:");
    console.log("   User ID:", mealPlanResponse.data.user_id);
    console.log(
      "   Diet Types:",
      mealPlanResponse.data.diet_constraints.diet_types.join(", "),
    );
    console.log(
      "   Excluded:",
      mealPlanResponse.data.diet_constraints.excluded_ingredients
        .slice(0, 3)
        .join(", "),
    );
    console.log(
      "   Target Calories:",
      mealPlanResponse.data.goal_profile.target_calories,
    );
    console.log(
      "   Daily Calories:",
      mealPlanResponse.data.meal_plan.daily_calories,
    );
    console.log(
      "   Meals Generated:",
      mealPlanResponse.data.meal_plan.meals.length,
    );
    console.log("\n🍳 Sample Meals:");
    mealPlanResponse.data.meal_plan.meals.forEach((meal) => {
      console.log(
        `   ${meal.meal_type}: ${meal.recipe_name} (${Math.round(meal.estimated_calories)} cal)`,
      );
    });

    console.log("\n✅ INTEGRATION SUCCESSFUL!");
    console.log("   ✓ Body profile from upstream function");
    console.log("   ✓ No duplicate BMR/TDEE calculations");
    console.log("   ✓ Meal plan generated with proper constraints");
  } catch (error) {
    console.error("❌ Error in meal plan pipeline:", error.message);
    if (error.response?.data) {
      console.error(
        "AI Service Error:",
        JSON.stringify(error.response.data, null, 2),
      );
    }
  }
}

/**
 * Run all examples
 */
async function runAllExamples() {
  console.log("╔════════════════════════════════════════╗");
  console.log("║   AI Service Usage Examples           ║");
  console.log("╚════════════════════════════════════════╝\n");

  // Check if MongoDB is connected
  const mongoose = require("mongoose");
  if (mongoose.connection.readyState !== 1) {
    console.log("⚠️  MongoDB is not connected. Connecting...");
    await require("./src/config/mongo");
  }

  // Run examples
  await exampleGenerateMealPlan();
  await exampleGetUserData();
  await exampleGetMealPlans();
  await exampleGetRecommendedRecipes();
  await exampleDirectAICall();
  await exampleCompleteWorkflow();
  await exampleMealPlanPipeline(); // New integration example

  console.log("\n╔════════════════════════════════════════╗");
  console.log("║   All examples completed!             ║");
  console.log("╚════════════════════════════════════════╝");
}

// Export functions for use in other files
module.exports = {
  exampleGenerateMealPlan,
  exampleGetUserData,
  exampleGetMealPlans,
  exampleGetRecommendedRecipes,
  exampleDirectAICall,
  exampleCompleteWorkflow,
  exampleMealPlanPipeline, // New integration example
  runAllExamples,
};

// Run examples if this file is executed directly
if (require.main === module) {
  runAllExamples()
    .then(() => {
      console.log("\n✅ Examples completed successfully");
      process.exit(0);
    })
    .catch((error) => {
      console.error("\n❌ Examples failed:", error);
      process.exit(1);
    });
}
