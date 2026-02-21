/**
 * Test script to verify connection between Node.js backend and Python AI service
 * Run this after starting both services
 */

const axios = require("axios");

const BACKEND_URL = "http://localhost:3000";
const AI_SERVICE_URL = "http://localhost:8000";

// Colors for console output
const colors = {
  green: "\x1b[32m",
  red: "\x1b[31m",
  yellow: "\x1b[33m",
  blue: "\x1b[36m",
  reset: "\x1b[0m",
};

function log(message, color = "reset") {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

async function testAIServiceDirectly() {
  log("\n=== Test 1: Direct AI Service Health Check ===", "blue");

  try {
    const response = await axios.get(`${AI_SERVICE_URL}/api/v1/health`);
    log("✓ AI Service is running", "green");
    log(`  Response: ${JSON.stringify(response.data)}`, "green");
    return true;
  } catch (error) {
    log("✗ AI Service is not available", "red");
    log(`  Error: ${error.message}`, "red");
    return false;
  }
}

async function testAIServiceRoot() {
  log("\n=== Test 2: AI Service Root Endpoint ===", "blue");

  try {
    const response = await axios.get(`${AI_SERVICE_URL}/`);
    log("✓ AI Service root endpoint accessible", "green");
    log(`  Response: ${JSON.stringify(response.data)}`, "green");
    return true;
  } catch (error) {
    log("✗ AI Service root endpoint not accessible", "red");
    log(`  Error: ${error.message}`, "red");
    return false;
  }
}

async function testBackendHealth() {
  log("\n=== Test 3: Backend Health Check ===", "blue");

  try {
    const response = await axios.get(`${BACKEND_URL}/api/health`);
    log("✓ Backend is running", "green");
    log(`  Response: ${JSON.stringify(response.data)}`, "green");
    return true;
  } catch (error) {
    log("✗ Backend is not available", "red");
    log(`  Error: ${error.message}`, "red");
    return false;
  }
}

async function testBackendToAIConnection() {
  log("\n=== Test 4: Backend → AI Service Health Check ===", "blue");

  try {
    const response = await axios.get(`${BACKEND_URL}/api/ai/health`);
    log("✓ Backend can connect to AI service", "green");
    log(`  Response: ${JSON.stringify(response.data)}`, "green");
    return true;
  } catch (error) {
    log("✗ Backend cannot connect to AI service", "red");
    log(`  Error: ${error.message}`, "red");
    if (error.response) {
      log(`  Status: ${error.response.status}`, "red");
      log(`  Data: ${JSON.stringify(error.response.data)}`, "red");
    }
    return false;
  }
}

async function testMealPlanGeneration() {
  log("\n=== Test 5: Meal Plan Generation (Mock) ===", "blue");

  try {
    const payload = {
      user_id: "test_user_123",
      days: 7,
      use_ml: false,
      user_data: {
        profile: {
          age: 30,
          gender: "male",
          height: 175,
          weight: 75,
        },
      },
    };

    log("  Sending request to AI service...", "yellow");
    const response = await axios.post(
      `${AI_SERVICE_URL}/api/v1/meal-planning/generate`,
      payload,
    );

    log("✓ Meal plan generated successfully", "green");
    log(`  Response: ${JSON.stringify(response.data, null, 2)}`, "green");
    return true;
  } catch (error) {
    log("✗ Failed to generate meal plan", "red");
    log(`  Error: ${error.message}`, "red");
    if (error.response) {
      log(`  Status: ${error.response.status}`, "red");
      log(`  Data: ${JSON.stringify(error.response.data)}`, "red");
    }
    return false;
  }
}

async function testBackendMealPlanGeneration() {
  log("\n=== Test 6: Meal Plan Generation via Backend ===", "blue");

  try {
    const payload = {
      userId: "test_user_123",
      days: 7,
      useML: false,
    };

    log("  Sending request to backend...", "yellow");
    const response = await axios.post(
      `${BACKEND_URL}/api/ai/meal-plan/generate`,
      payload,
    );

    log("✓ Meal plan generated via backend successfully", "green");
    log(`  Response: ${JSON.stringify(response.data, null, 2)}`, "green");
    return true;
  } catch (error) {
    log("✗ Failed to generate meal plan via backend", "red");
    log(`  Error: ${error.message}`, "red");
    if (error.response) {
      log(`  Status: ${error.response.status}`, "red");
      log(`  Data: ${JSON.stringify(error.response.data)}`, "red");
    }
    return false;
  }
}

async function runAllTests() {
  log("\n╔════════════════════════════════════════════════════════╗", "blue");
  log("║  AI Service Connection Test Suite                     ║", "blue");
  log("╚════════════════════════════════════════════════════════╝", "blue");

  const results = {
    aiServiceHealth: await testAIServiceDirectly(),
    aiServiceRoot: await testAIServiceRoot(),
    backendHealth: await testBackendHealth(),
    backendToAI: await testBackendToAIConnection(),
    mealPlanGeneration: await testMealPlanGeneration(),
    backendMealPlanGeneration: await testBackendMealPlanGeneration(),
  };

  // Summary
  log("\n╔════════════════════════════════════════════════════════╗", "blue");
  log("║  Test Results Summary                                  ║", "blue");
  log("╚════════════════════════════════════════════════════════╝", "blue");

  const passed = Object.values(results).filter(Boolean).length;
  const total = Object.keys(results).length;

  log(`\nTotal Tests: ${total}`, "blue");
  log(`Passed: ${passed}`, passed === total ? "green" : "yellow");
  log(`Failed: ${total - passed}`, total - passed === 0 ? "green" : "red");

  Object.entries(results).forEach(([test, result]) => {
    const status = result ? "✓ PASS" : "✗ FAIL";
    const color = result ? "green" : "red";
    log(`  ${status} - ${test}`, color);
  });

  if (passed === total) {
    log("\n🎉 All tests passed! Connection is working properly.", "green");
  } else {
    log("\n⚠️  Some tests failed. Please check the services.", "yellow");
    log("\nTroubleshooting tips:", "yellow");
    log(
      "  1. Make sure the AI service is running: cd ai_meal_planing_service && uvicorn app.main:app --reload --port 8000",
    );
    log(
      "  2. Make sure the backend is running: cd eater-backend && npm run dev",
    );
    log("  3. Check that MongoDB is running");
    log("  4. Verify .env files are configured correctly");
  }

  log("\n");
}

// Run tests
runAllTests()
  .then(() => {
    process.exit(0);
  })
  .catch((error) => {
    log(`\nUnexpected error: ${error.message}`, "red");
    process.exit(1);
  });
