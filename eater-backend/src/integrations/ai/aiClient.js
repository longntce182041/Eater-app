const axios = require("axios");

const aiClient = axios.create({
  baseURL: process.env.AI_SERVICE_URL || "http://localhost:8000",
  timeout: 10000,
});

async function generateMealPlan(payload) {
  // POST to Python FastAPI AI service
  return aiClient.post("/meal-plans/generate", payload);
}

module.exports = {
  generateMealPlan,
};
