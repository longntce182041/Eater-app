const axios = require("axios");

// ANSI color codes for console output
const colors = {
  reset: "\x1b[0m",
  green: "\x1b[32m",
  red: "\x1b[31m",
  yellow: "\x1b[33m",
  blue: "\x1b[34m",
  cyan: "\x1b[36m",
};

const BACKEND_URL = process.env.BACKEND_URL || "http://localhost:3000";
const AI_SERVICE_URL = process.env.AI_SERVICE_URL || "http://localhost:8000";

console.log("\n╔════════════════════════════════════════════════════════╗");
console.log("║  User Profile Analysis Test Suite                     ║");
console.log("╚════════════════════════════════════════════════════════╝\n");

// Test data
const testUserProfile = {
  user_id: "test_user_analysis_123",
  age: 30,
  gender: "male",
  height_cm: 175,
  weight_kg: 75,
  goal_weight_kg: 70,
  health_goals: "weight_loss",
  activity_level: "moderate",
};

const testResults = {
  passed: 0,
  failed: 0,
  tests: [],
};

/**
 * Test 1: Direct AI Service - Analyze User Profile
 */
async function testDirectAIAnalysis() {
  console.log("=== Test 1: Direct AI Service - User Profile Analysis ===");
  try {
    const response = await axios.post(
      `${AI_SERVICE_URL}/api/user-profile/analyze`,
      testUserProfile,
      { timeout: 10000 },
    );

    if (
      response.status === 200 &&
      response.data.user_id === testUserProfile.user_id
    ) {
      console.log(
        `${colors.green}✓${colors.reset} AI Service analyzed profile successfully`,
      );
      console.log(`  BMR: ${response.data.health_metrics.bmr} calories/day`);
      console.log(`  TDEE: ${response.data.health_metrics.tdee} calories/day`);
      console.log(
        `  Target: ${response.data.health_metrics.target_calories} calories/day`,
      );
      console.log(
        `  BMI: ${response.data.bmi} (${response.data.bmi_category})`,
      );
      testResults.passed++;
      testResults.tests.push("directAIAnalysis");
      return true;
    } else {
      throw new Error("Invalid response format");
    }
  } catch (error) {
    console.log(`${colors.red}✗${colors.reset} AI Service analysis failed`);
    console.log(`  Error: ${error.response?.data?.detail || error.message}`);
    testResults.failed++;
    return false;
  }
  console.log();
}

/**
 * Test 2: Test Different Activity Levels
 */
async function testActivityLevels() {
  console.log("\n=== Test 2: Different Activity Levels ===");
  const activityLevels = [
    "sedentary",
    "light",
    "moderate",
    "active",
    "very_active",
  ];
  let allPassed = true;

  for (const level of activityLevels) {
    try {
      const response = await axios.post(
        `${AI_SERVICE_URL}/api/user-profile/analyze`,
        { ...testUserProfile, activity_level: level },
        { timeout: 10000 },
      );

      console.log(
        `${colors.green}✓${colors.reset} ${level}: TDEE = ${response.data.health_metrics.tdee} cal/day`,
      );
    } catch (error) {
      console.log(`${colors.red}✗${colors.reset} ${level}: Failed`);
      allPassed = false;
    }
  }

  if (allPassed) {
    testResults.passed++;
    testResults.tests.push("activityLevels");
  } else {
    testResults.failed++;
  }
  console.log();
}

/**
 * Test 3: Test Different Health Goals
 */
async function testHealthGoals() {
  console.log("\n=== Test 3: Different Health Goals ===");
  const healthGoals = [
    "weight_loss",
    "weight_gain",
    "muscle_gain",
    "maintenance",
  ];
  let allPassed = true;

  for (const goal of healthGoals) {
    try {
      const response = await axios.post(
        `${AI_SERVICE_URL}/api/user-profile/analyze`,
        { ...testUserProfile, health_goals: goal },
        { timeout: 10000 },
      );

      console.log(
        `${colors.green}✓${colors.reset} ${goal}: Target = ${response.data.health_metrics.target_calories} cal/day`,
      );
    } catch (error) {
      console.log(`${colors.red}✗${colors.reset} ${goal}: Failed`);
      allPassed = false;
    }
  }

  if (allPassed) {
    testResults.passed++;
    testResults.tests.push("healthGoals");
  } else {
    testResults.failed++;
  }
  console.log();
}

/**
 * Test 4: Test Gender Differences
 */
async function testGenderDifferences() {
  console.log("\n=== Test 4: Gender Differences in BMR ===");
  const genders = ["male", "female", "other"];
  let allPassed = true;

  for (const gender of genders) {
    try {
      const response = await axios.post(
        `${AI_SERVICE_URL}/api/user-profile/analyze`,
        { ...testUserProfile, gender },
        { timeout: 10000 },
      );

      console.log(
        `${colors.green}✓${colors.reset} ${gender}: BMR = ${response.data.health_metrics.bmr} cal/day`,
      );
    } catch (error) {
      console.log(`${colors.red}✗${colors.reset} ${gender}: Failed`);
      allPassed = false;
    }
  }

  if (allPassed) {
    testResults.passed++;
    testResults.tests.push("genderDifferences");
  } else {
    testResults.failed++;
  }
  console.log();
}

/**
 * Test 5: Test BMI Categories
 */
async function testBMICategories() {
  console.log("\n=== Test 5: BMI Categories ===");
  const testCases = [
    { weight: 55, expected: "underweight" },
    { weight: 70, expected: "normal_weight" },
    { weight: 85, expected: "overweight" },
    { weight: 100, expected: "obese" },
  ];
  let allPassed = true;

  for (const testCase of testCases) {
    try {
      const response = await axios.post(
        `${AI_SERVICE_URL}/api/user-profile/analyze`,
        { ...testUserProfile, weight_kg: testCase.weight },
        { timeout: 10000 },
      );

      const passed = response.data.bmi_category === testCase.expected;
      if (passed) {
        console.log(
          `${colors.green}✓${colors.reset} Weight ${testCase.weight}kg: BMI ${response.data.bmi} (${response.data.bmi_category})`,
        );
      } else {
        console.log(
          `${colors.red}✗${colors.reset} Weight ${testCase.weight}kg: Expected ${testCase.expected}, got ${response.data.bmi_category}`,
        );
        allPassed = false;
      }
    } catch (error) {
      console.log(
        `${colors.red}✗${colors.reset} Weight ${testCase.weight}kg: Failed`,
      );
      allPassed = false;
    }
  }

  if (allPassed) {
    testResults.passed++;
    testResults.tests.push("bmiCategories");
  } else {
    testResults.failed++;
  }
  console.log();
}

/**
 * Test 6: Test Invalid Input Validation
 */
async function testValidation() {
  console.log("\n=== Test 6: Input Validation ===");
  const invalidCases = [
    {
      data: { ...testUserProfile, activity_level: "invalid" },
      name: "Invalid activity level",
    },
    { data: { ...testUserProfile, gender: "invalid" }, name: "Invalid gender" },
    { data: { ...testUserProfile, age: -5 }, name: "Negative age" },
  ];
  let allPassed = true;

  for (const testCase of invalidCases) {
    try {
      await axios.post(
        `${AI_SERVICE_URL}/api/user-profile/analyze`,
        testCase.data,
        { timeout: 10000 },
      );
      console.log(
        `${colors.red}✗${colors.reset} ${testCase.name}: Should have failed`,
      );
      allPassed = false;
    } catch (error) {
      if (error.response?.status === 400 || error.response?.status === 422) {
        console.log(
          `${colors.green}✓${colors.reset} ${testCase.name}: Correctly rejected`,
        );
      } else {
        console.log(
          `${colors.red}✗${colors.reset} ${testCase.name}: Wrong error status`,
        );
        allPassed = false;
      }
    }
  }

  if (allPassed) {
    testResults.passed++;
    testResults.tests.push("validation");
  } else {
    testResults.failed++;
  }
  console.log();
}

/**
 * Run all tests
 */
async function runTests() {
  await testDirectAIAnalysis();
  await testActivityLevels();
  await testHealthGoals();
  await testGenderDifferences();
  await testBMICategories();
  await testValidation();

  // Print summary
  console.log("\n╔════════════════════════════════════════════════════════╗");
  console.log("║  Test Results Summary                                  ║");
  console.log("╚════════════════════════════════════════════════════════╝\n");

  console.log(`Total Tests: ${testResults.passed + testResults.failed}`);
  console.log(`${colors.green}Passed: ${testResults.passed}${colors.reset}`);
  console.log(`${colors.red}Failed: ${testResults.failed}${colors.reset}`);

  if (testResults.failed === 0) {
    console.log(`\n${colors.green}✓ All tests passed!${colors.reset}\n`);
  } else {
    console.log(
      `\n${colors.red}⚠️  Some tests failed. Please check the services.${colors.reset}\n`,
    );
  }

  console.log("Troubleshooting tips:");
  console.log(
    "  1. Make sure the AI service is running: python -m uvicorn app.main:app --reload --port 8000",
  );
  console.log("  2. Check AI service at: http://localhost:8000/docs");
  console.log(
    "  3. Verify all Python dependencies are installed: pip install -r requirements.txt\n",
  );
}

// Run tests
runTests().catch((error) => {
  console.error(
    `${colors.red}Test suite failed:${colors.reset}`,
    error.message,
  );
  process.exit(1);
});
