const {
  updateHealthInfoSchema,
  createHealthInfoSchema,
} = require("../../api/validators/health.validators");

describe("Health Validators", () => {
  describe("updateHealthInfoSchema", () => {
    test("should accept valid partial update data", () => {
      const data = {
        weight: 70,
        activityLevel: "active",
      };

      const { error } = updateHealthInfoSchema.validate(data);
      expect(error).toBeUndefined();
    });

    test("should accept all valid fields", () => {
      const data = {
        age: 30,
        gender: "male",
        height: 180,
        weight: 75,
        dietaryPreferences: ["vegetarian"],
        allergies: ["peanuts"],
        activityLevel: "moderate",
        healthGoals: "weight loss",
        cookingSkillLevel: "intermediate",
        available_cooking_time: 30,
        daily_calorie_target: 2000,
      };

      const { error } = updateHealthInfoSchema.validate(data);
      expect(error).toBeUndefined();
    });

    test("should reject invalid age", () => {
      const data = { age: 151 };
      const { error } = updateHealthInfoSchema.validate(data);
      expect(error).toBeDefined();
      expect(error.details[0].message).toContain(
        "must be less than or equal to 150",
      );
    });

    test("should reject negative weight", () => {
      const data = { weight: -10 };
      const { error } = updateHealthInfoSchema.validate(data);
      expect(error).toBeDefined();
    });

    test("should reject invalid gender", () => {
      const data = { gender: "invalid" };
      const { error } = updateHealthInfoSchema.validate(data);
      expect(error).toBeDefined();
      expect(error.details[0].message).toContain("must be one of");
    });

    test("should reject invalid activity level", () => {
      const data = { activityLevel: "super active" };
      const { error } = updateHealthInfoSchema.validate(data);
      expect(error).toBeDefined();
    });

    test("should reject invalid cooking skill level", () => {
      const data = { cookingSkillLevel: "expert" };
      const { error } = updateHealthInfoSchema.validate(data);
      expect(error).toBeDefined();
    });

    test("should accept empty object (all fields optional)", () => {
      const data = {};
      const { error } = updateHealthInfoSchema.validate(data);
      expect(error).toBeUndefined();
    });

    test("should reject cooking time > 1440 minutes", () => {
      const data = { available_cooking_time: 1441 };
      const { error } = updateHealthInfoSchema.validate(data);
      expect(error).toBeDefined();
    });

    test("should accept valid dietary preferences array", () => {
      const data = { dietaryPreferences: ["vegetarian", "gluten-free"] };
      const { error } = updateHealthInfoSchema.validate(data);
      expect(error).toBeUndefined();
    });

    test("should accept valid allergies array", () => {
      const data = { allergies: ["peanuts", "shellfish"] };
      const { error } = updateHealthInfoSchema.validate(data);
      expect(error).toBeUndefined();
    });

    test("should reject health goals > 500 characters", () => {
      const data = { healthGoals: "a".repeat(501) };
      const { error } = updateHealthInfoSchema.validate(data);
      expect(error).toBeDefined();
    });

    test("should reject invalid calorie target", () => {
      const data = { daily_calorie_target: 10001 };
      const { error } = updateHealthInfoSchema.validate(data);
      expect(error).toBeDefined();
    });
  });

  describe("createHealthInfoSchema", () => {
    test("should accept valid complete health info", () => {
      const data = {
        age: 30,
        gender: "male",
        height: 180,
        weight: 75,
        activityLevel: "moderate",
      };

      const { error } = createHealthInfoSchema.validate(data);
      expect(error).toBeUndefined();
    });

    test("should reject missing required age", () => {
      const data = {
        gender: "male",
        height: 180,
        weight: 75,
        activityLevel: "moderate",
      };

      const { error } = createHealthInfoSchema.validate(data);
      expect(error).toBeDefined();
      expect(error.details[0].message).toContain("is required");
    });

    test("should reject missing required gender", () => {
      const data = {
        age: 30,
        height: 180,
        weight: 75,
        activityLevel: "moderate",
      };

      const { error } = createHealthInfoSchema.validate(data);
      expect(error).toBeDefined();
    });

    test("should reject missing required height", () => {
      const data = {
        age: 30,
        gender: "male",
        weight: 75,
        activityLevel: "moderate",
      };

      const { error } = createHealthInfoSchema.validate(data);
      expect(error).toBeDefined();
    });

    test("should reject missing required weight", () => {
      const data = {
        age: 30,
        gender: "male",
        height: 180,
        activityLevel: "moderate",
      };

      const { error } = createHealthInfoSchema.validate(data);
      expect(error).toBeDefined();
    });

    test("should reject missing required activity level", () => {
      const data = {
        age: 30,
        gender: "male",
        height: 180,
        weight: 75,
      };

      const { error } = createHealthInfoSchema.validate(data);
      expect(error).toBeDefined();
    });

    test("should allow optional fields in create schema", () => {
      const data = {
        age: 30,
        gender: "male",
        height: 180,
        weight: 75,
        activityLevel: "moderate",
        dietaryPreferences: ["vegetarian"],
        healthGoals: "lose weight",
      };

      const { error } = createHealthInfoSchema.validate(data);
      expect(error).toBeUndefined();
    });

    test("should reject invalid age in create schema", () => {
      const data = {
        age: 0,
        gender: "male",
        height: 180,
        weight: 75,
        activityLevel: "moderate",
      };

      const { error } = createHealthInfoSchema.validate(data);
      expect(error).toBeDefined();
    });

    test("should accept height at minimum boundary", () => {
      const data = {
        age: 30,
        gender: "male",
        height: 50,
        weight: 75,
        activityLevel: "moderate",
      };

      const { error } = createHealthInfoSchema.validate(data);
      expect(error).toBeUndefined();
    });

    test("should reject height below minimum", () => {
      const data = {
        age: 30,
        gender: "male",
        height: 49,
        weight: 75,
        activityLevel: "moderate",
      };

      const { error } = createHealthInfoSchema.validate(data);
      expect(error).toBeDefined();
    });
  });
});
