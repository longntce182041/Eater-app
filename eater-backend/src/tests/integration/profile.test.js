// Integration tests for Profile API endpoints
const mongoose = require("mongoose");
const request = require("supertest");
const app = require("../../app");
const User = require("../../models/User");
const { User_Profile } = require("../../models/User_Profile");
const bcrypt = require("bcrypt");

describe("Profile API Tests", () => {
    let testUserId;
    let accessToken;

    // Setup: Create test user and get token
    beforeAll(async () => {
        // Create a test user
        const testUser = await User.create({
            email: "profile-test@example.com",
            passwordHash: await bcrypt.hash("Password123", 10),
            role: "user",
            isActive: true,
            isEmailVerified: true,
        });

        testUserId = testUser._id.toString();

        // Generate token for testing (normally done via login)
        const jwt = require("jsonwebtoken");
        const { jwtConfig } = require("../../config/jwt");
        accessToken = jwt.sign(
            { sub: testUserId, role: "user" },
            jwtConfig.secret,
            { expiresIn: "24h" }
        );
    });

    // Cleanup: Remove test data
    afterAll(async () => {
        await User.deleteOne({ email: "profile-test@example.com" });
        await User_Profile.deleteOne({ userId: testUserId });
        await mongoose.connection.close();
    });

    describe("POST /api/profile - Create Profile", () => {
        it("Should create a new profile with all required fields", async () => {
            const response = await request(app)
                .post("/api/profile")
                .set("Authorization", `Bearer ${accessToken}`)
                .send({
                    age: 30,
                    gender: "male",
                    height: 175,
                    weight: 75,
                    activityLevel: "moderate",
                    dietaryPreferences: ["vegetarian"],
                    allergies: [],
                    healthGoals: "Weight loss",
                    cookingSkillLevel: "intermediate",
                    available_cooking_time: 45,
                    daily_calorie_target: 2200,
                });

            expect(response.status).toBe(201);
            expect(response.body.status).toBe("success");
            expect(response.body.message).toBe("Profile created successfully");
            expect(response.body.data.age).toBe(30);
            expect(response.body.data.gender).toBe("male");
        });

        it("Should fail when creating profile without required fields", async () => {
            // Try to create profile without age
            const response = await request(app)
                .post("/api/profile")
                .set("Authorization", `Bearer ${accessToken}`)
                .send({
                    gender: "female",
                    height: 165,
                    weight: 60,
                    activityLevel: "light",
                });

            expect(response.status).toBe(400);
            expect(response.body.status).toBe("fail");
            expect(response.body.message).toBe("Validation failed");
            expect(response.body.errors.length).toBeGreaterThan(0);
        });

        it("Should fail when creating profile without authentication token", async () => {
            const response = await request(app).post("/api/profile").send({
                age: 30,
                gender: "male",
                height: 175,
                weight: 75,
                activityLevel: "moderate",
            });

            expect(response.status).toBe(401);
            expect(response.body.message).toBe("Authentication token missing");
        });

        it("Should fail with invalid activity level", async () => {
            const response = await request(app)
                .post("/api/profile")
                .set("Authorization", `Bearer ${accessToken}`)
                .send({
                    age: 30,
                    gender: "male",
                    height: 175,
                    weight: 75,
                    activityLevel: "invalid_level", // Invalid value
                });

            expect(response.status).toBe(400);
            expect(response.body.errors[0].message).toContain("Activity level must be");
        });
    });

    describe("GET /api/profile - View Profile", () => {
        it("Should retrieve user profile successfully", async () => {
            // First create a profile
            await request(app)
                .post("/api/profile")
                .set("Authorization", `Bearer ${accessToken}`)
                .send({
                    age: 28,
                    gender: "female",
                    height: 165,
                    weight: 60,
                    activityLevel: "light",
                });

            // Then retrieve it
            const response = await request(app)
                .get("/api/profile")
                .set("Authorization", `Bearer ${accessToken}`);

            expect(response.status).toBe(200);
            expect(response.body.status).toBe("success");
            expect(response.body.message).toBe("Profile retrieved successfully");
            expect(response.body.data.age).toBe(28);
            expect(response.body.data.gender).toBe("female");
            expect(response.body.data.userId).toBeDefined();
            expect(response.body.data.userId.email).toBe("profile-test@example.com");
        });

        it("Should fail to retrieve profile without authentication", async () => {
            const response = await request(app).get("/api/profile");

            expect(response.status).toBe(401);
            expect(response.body.message).toBe("Authentication token missing");
        });

        it("Should fail with invalid JWT token", async () => {
            const response = await request(app)
                .get("/api/profile")
                .set("Authorization", "Bearer invalid_token_here");

            expect(response.status).toBe(401);
            expect(response.body.message).toContain("Invalid");
        });
    });

    describe("PUT /api/profile - Update Profile", () => {
        beforeEach(async () => {
            // Ensure profile exists before each update test
            await User_Profile.deleteOne({ userId: testUserId });
            await request(app)
                .post("/api/profile")
                .set("Authorization", `Bearer ${accessToken}`)
                .send({
                    age: 30,
                    gender: "male",
                    height: 175,
                    weight: 75,
                    activityLevel: "moderate",
                });
        });

        it("Should update single field in profile", async () => {
            const response = await request(app)
                .put("/api/profile")
                .set("Authorization", `Bearer ${accessToken}`)
                .send({
                    weight: 72,
                });

            expect(response.status).toBe(200);
            expect(response.body.status).toBe("success");
            expect(response.body.message).toBe("Profile updated successfully");
            expect(response.body.data.weight).toBe(72);
            expect(response.body.data.age).toBe(30); // Unchanged field
        });

        it("Should update multiple fields in profile", async () => {
            const response = await request(app)
                .put("/api/profile")
                .set("Authorization", `Bearer ${accessToken}`)
                .send({
                    weight: 70,
                    activityLevel: "active",
                    cookingSkillLevel: "advanced",
                    daily_calorie_target: 2400,
                });

            expect(response.status).toBe(200);
            expect(response.body.data.weight).toBe(70);
            expect(response.body.data.activityLevel).toBe("active");
            expect(response.body.data.cookingSkillLevel).toBe("advanced");
            expect(response.body.data.daily_calorie_target).toBe(2400);
        });

        it("Should update dietary preferences array", async () => {
            const response = await request(app)
                .put("/api/profile")
                .set("Authorization", `Bearer ${accessToken}`)
                .send({
                    dietaryPreferences: ["vegetarian", "gluten-free", "vegan"],
                });

            expect(response.status).toBe(200);
            expect(response.body.data.dietaryPreferences).toContain("vegetarian");
            expect(response.body.data.dietaryPreferences).toContain("gluten-free");
            expect(response.body.data.dietaryPreferences).toContain("vegan");
            expect(response.body.data.dietaryPreferences.length).toBe(3);
        });

        it("Should fail with invalid weight (negative)", async () => {
            const response = await request(app)
                .put("/api/profile")
                .set("Authorization", `Bearer ${accessToken}`)
                .send({
                    weight: -50,
                });

            expect(response.status).toBe(400);
            expect(response.body.errors[0].message).toContain("greater than 0");
        });

        it("Should fail with invalid age (out of range)", async () => {
            const response = await request(app)
                .put("/api/profile")
                .set("Authorization", `Bearer ${accessToken}`)
                .send({
                    age: 200,
                });

            expect(response.status).toBe(400);
            expect(response.body.errors[0].message).toContain("must not exceed 150");
        });

        it("Should fail when sending empty update body", async () => {
            const response = await request(app)
                .put("/api/profile")
                .set("Authorization", `Bearer ${accessToken}`)
                .send({});

            expect(response.status).toBe(400);
            expect(response.body.errors[0].message).toContain("At least one field");
        });

        it("Should fail with invalid cooking skill level", async () => {
            const response = await request(app)
                .put("/api/profile")
                .set("Authorization", `Bearer ${accessToken}`)
                .send({
                    cookingSkillLevel: "expert", // Invalid value
                });

            expect(response.status).toBe(400);
            expect(response.body.errors[0].message).toContain("beginner, intermediate, advanced");
        });

        it("Should fail without authentication token", async () => {
            const response = await request(app)
                .put("/api/profile")
                .send({
                    weight: 70,
                });

            expect(response.status).toBe(401);
        });

        it("Should fail when profile doesn't exist", async () => {
            // Create new user without profile
            const newUser = await User.create({
                email: "no-profile@example.com",
                passwordHash: await bcrypt.hash("Password123", 10),
                isActive: true,
            });

            const jwt = require("jsonwebtoken");
            const { jwtConfig } = require("../../config/jwt");
            const newToken = jwt.sign(
                { sub: newUser._id.toString(), role: "user" },
                jwtConfig.secret,
                { expiresIn: "24h" }
            );

            const response = await request(app)
                .put("/api/profile")
                .set("Authorization", `Bearer ${newToken}`)
                .send({
                    weight: 70,
                });

            expect(response.status).toBe(404);
            expect(response.body.message).toContain("User profile not found");

            // Cleanup
            await User.deleteOne({ _id: newUser._id });
        });
    });

    describe("Edge Cases", () => {
        it("Should handle very long health goals string (max 500 chars)", async () => {
            const longGoals = "a".repeat(500);

            const response = await request(app)
                .post("/api/profile")
                .set("Authorization", `Bearer ${accessToken}`)
                .send({
                    age: 30,
                    gender: "male",
                    height: 175,
                    weight: 75,
                    activityLevel: "moderate",
                    healthGoals: longGoals,
                });

            expect(response.status).toBe(201);
            expect(response.body.data.healthGoals.length).toBe(500);
        });

        it("Should fail with health goals > 500 chars", async () => {
            const tooLongGoals = "a".repeat(501);

            const response = await request(app)
                .post("/api/profile")
                .set("Authorization", `Bearer ${accessToken}`)
                .send({
                    age: 30,
                    gender: "male",
                    height: 175,
                    weight: 75,
                    activityLevel: "moderate",
                    healthGoals: tooLongGoals,
                });

            expect(response.status).toBe(400);
            expect(response.body.errors[0].message).toContain("500 characters");
        });

        it("Should accept decimal values for height and weight", async () => {
            const response = await request(app)
                .post("/api/profile")
                .set("Authorization", `Bearer ${accessToken}`)
                .send({
                    age: 30,
                    gender: "male",
                    height: 175.5,
                    weight: 75.3,
                    activityLevel: "moderate",
                });

            expect(response.status).toBe(201);
            expect(response.body.data.height).toBe(175.5);
            expect(response.body.data.weight).toBe(75.3);
        });
    });
});
