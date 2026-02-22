const axios = require("axios");

const aiClient = axios.create({
  baseURL: process.env.AI_SERVICE_URL || "http://localhost:8000",
  timeout: 30000, // Increased timeout for AI processing
  headers: {
    "Content-Type": "application/json",
  },
});

// Request interceptor for logging
aiClient.interceptors.request.use(
  (config) => {
    console.log(
      `AI Service Request: ${config.method.toUpperCase()} ${config.url}`,
    );
    return config;
  },
  (error) => {
    console.error("AI Service Request Error:", error);
    return Promise.reject(error);
  },
);

// Response interceptor for error handling
aiClient.interceptors.response.use(
  (response) => {
    console.log(
      `AI Service Response: ${response.status} ${response.config.url}`,
    );
    return response;
  },
  (error) => {
    if (error.response) {
      // Server responded with error status
      console.error("AI Service Error Response:", {
        status: error.response.status,
        data: error.response.data,
        url: error.config?.url,
      });
    } else if (error.request) {
      // Request made but no response
      console.error("AI Service No Response:", {
        url: error.config?.url,
        message: error.message,
      });
    } else {
      // Error in request setup
      console.error("AI Service Request Setup Error:", error.message);
    }
    return Promise.reject(error);
  },
);

/**
 * Generate meal plan through AI service
 * @param {Object} payload - Meal plan generation payload
 * @returns {Promise<Object>} Generated meal plan
 */
async function generateMealPlan(payload) {
  try {
    const response = await aiClient.post(
      "/api/meal-planning/generate",
      payload,
    );
    return response;
  } catch (error) {
    throw new Error(`Meal plan generation failed: ${error.message}`);
  }
}

/**
 * Health check for AI service
 * @returns {Promise<Object>} Health status
 */
async function healthCheck() {
  try {
    const response = await aiClient.get("/api/health");
    return response.data;
  } catch (error) {
    throw new Error(`AI service health check failed: ${error.message}`);
  }
}

/**
 * Get AI service status and capabilities
 * @returns {Promise<Object>} Service status
 */
async function getServiceStatus() {
  try {
    const response = await aiClient.get("/api/status");
    return response.data;
  } catch (error) {
    console.warn("Could not fetch AI service status:", error.message);
    return {
      available: false,
      error: error.message,
    };
  }
}

/**
 * Analyze user profile and calculate health metrics
 * @param {Object} userProfile - User profile data
 * @returns {Promise<Object>} Health metrics and analysis
 */
async function analyzeUserProfile(userProfile) {
  try {
    const response = await aiClient.post(
      "/api/user-profile/analyze",
      userProfile,
    );
    return response.data;
  } catch (error) {
    throw new Error(`User profile analysis failed: ${error.message}`);
  }
}

/**
 * Generate meal plan using complete AI pipeline with recipe database
 * @param {Object} params - Pipeline parameters
 * @param {string} params.user_id - User identifier
 * @param {Object} params.body_profile - Body profile from analyzeUserProfile
 * @param {Array<string>} params.diet_types - Diet type preferences
 * @param {Array<string>} params.allergies - Allergic ingredients
 * @param {Array<string>} params.disliked_ingredients - Disliked ingredients
 * @param {string} params.health_goal - Health goal (weight_loss, muscle_gain, maintain, etc.)
 * @param {number} params.days - Number of days to generate
 * @param {Array<Object>} params.recipe_database - Optional: Custom recipe database
 * @returns {Promise<Object>} Complete meal plan with all pipeline steps
 */
async function generateMealPlanPipeline(params) {
  try {
    const response = await aiClient.post(
      "/api/pipeline/complete-pipeline",
      params,
    );
    return response.data;
  } catch (error) {
    const errorMsg = error.response?.data?.detail || error.message;
    console.error(
      "Pipeline Error Details:",
      JSON.stringify(error.response?.data, null, 2),
    );
    throw new Error(
      `Meal plan pipeline failed: ${typeof errorMsg === "object" ? JSON.stringify(errorMsg) : errorMsg}`,
    );
  }
}

/**
 * Generate meal plan step 3 only (with custom recipe database)
 * @param {Object} params - Generation parameters
 * @param {Object} params.body_profile - User's metabolic data
 * @param {Object} params.diet_constraints - Diet constraints from step 1
 * @param {Object} params.goal_profile - Goal profile from step 2
 * @param {Array<Object>} params.recipe_database - Custom recipe database
 * @param {number} params.days - Number of days
 * @returns {Promise<Object>} Generated meal plan
 */
async function generateMealPlanWithRecipes(params) {
  try {
    const response = await aiClient.post(
      "/api/pipeline/step3/generate-meal-plan",
      params,
    );
    return response.data;
  } catch (error) {
    const errorMsg = error.response?.data?.detail || error.message;
    throw new Error(`Meal plan generation failed: ${errorMsg}`);
  }
}

/**
 * Get recipe database information
 * @returns {Promise<Object>} Recipe database info
 */
async function getRecipeDatabaseInfo() {
  try {
    const response = await aiClient.get("/api/recipe-database/info");
    return response.data;
  } catch (error) {
    throw new Error(
      `Failed to retrieve recipe database info: ${error.message}`,
    );
  }
}

module.exports = {
  aiClient,
  generateMealPlan,
  healthCheck,
  getServiceStatus,
  analyzeUserProfile,
  generateMealPlanPipeline,
  generateMealPlanWithRecipes,
  getRecipeDatabaseInfo,
};
