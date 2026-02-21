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

module.exports = {
  aiClient,
  generateMealPlan,
  healthCheck,
  getServiceStatus,
  analyzeUserProfile,
};
