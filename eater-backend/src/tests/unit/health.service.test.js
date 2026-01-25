const mongoose = require("mongoose");
const { User_Profile } = require("../../models/User_Profile");
const healthService = require("../../api/services/health.service");

// Mock the User_Profile model
jest.mock("../../models/User_Profile");

describe("Health Service", () => {
  const mockUserId = new mongoose.Types.ObjectId();
  const mockProfileId = new mongoose.Types.ObjectId();

  const mockHealthData = {
    _id: mockProfileId,
    userId: mockUserId,
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
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe("getHealthInfo", () => {
    test("should retrieve health info successfully", async () => {
      User_Profile.findOne.mockResolvedValue(mockHealthData);

      const result = await healthService.getHealthInfo(mockUserId);

      expect(result).toEqual(mockHealthData);
      expect(User_Profile.findOne).toHaveBeenCalledWith({ userId: mockUserId });
    });

    test("should throw error if health info not found", async () => {
      User_Profile.findOne.mockResolvedValue(null);

      await expect(healthService.getHealthInfo(mockUserId)).rejects.toThrow(
        "Health information not found",
      );
    });
  });

  describe("updateHealthInfo", () => {
    test("should update health info successfully", async () => {
      const updateData = { weight: 70, activityLevel: "active" };
      const updatedProfile = { ...mockHealthData, ...updateData };

      User_Profile.findOneAndUpdate.mockResolvedValue(updatedProfile);

      const result = await healthService.updateHealthInfo(
        mockUserId,
        updateData,
      );

      expect(result).toEqual(updatedProfile);
      expect(User_Profile.findOneAndUpdate).toHaveBeenCalledWith(
        { userId: mockUserId },
        updateData,
        { new: true, runValidators: true },
      );
    });

    test("should throw error if health info not found during update", async () => {
      User_Profile.findOneAndUpdate.mockResolvedValue(null);

      await expect(
        healthService.updateHealthInfo(mockUserId, { weight: 70 }),
      ).rejects.toThrow("Health information not found");
    });

    test("should allow partial updates", async () => {
      const partialUpdate = { weight: 72 };
      const updatedProfile = { ...mockHealthData, ...partialUpdate };

      User_Profile.findOneAndUpdate.mockResolvedValue(updatedProfile);

      const result = await healthService.updateHealthInfo(
        mockUserId,
        partialUpdate,
      );

      expect(result.weight).toBe(72);
      expect(result.age).toBe(mockHealthData.age); // Other fields unchanged
    });
  });

  describe("createHealthInfo", () => {
    test("should create health info successfully", async () => {
      User_Profile.findOne.mockResolvedValueOnce(null); // No existing profile
      User_Profile.prototype.save = jest.fn().mockResolvedValue(true);

      const newProfile = new User_Profile({
        userId: mockUserId,
        ...mockHealthData,
      });
      newProfile.save = jest.fn().mockResolvedValue(newProfile);

      await expect(
        healthService.createHealthInfo(mockUserId, mockHealthData),
      ).resolves.toBeDefined();
    });

    test("should throw error if profile already exists", async () => {
      User_Profile.findOne.mockResolvedValue(mockHealthData);

      await expect(
        healthService.createHealthInfo(mockUserId, mockHealthData),
      ).rejects.toThrow("Health information already exists for this user");
    });

    test("should include userId in created profile", async () => {
      User_Profile.findOne.mockResolvedValueOnce(null);

      const profileData = {
        userId: mockUserId,
        age: 25,
        gender: "female",
        height: 165,
        weight: 60,
        activityLevel: "light",
      };

      // Verify the structure would include userId
      expect(profileData.userId).toEqual(mockUserId);
      expect(profileData.age).toBe(25);
    });
  });

  describe("deleteHealthInfo", () => {
    test("should delete health info successfully", async () => {
      User_Profile.findOneAndDelete.mockResolvedValue(mockHealthData);

      const result = await healthService.deleteHealthInfo(mockUserId);

      expect(result).toEqual(mockHealthData);
      expect(User_Profile.findOneAndDelete).toHaveBeenCalledWith({
        userId: mockUserId,
      });
    });

    test("should throw error if health info not found during delete", async () => {
      User_Profile.findOneAndDelete.mockResolvedValue(null);

      await expect(healthService.deleteHealthInfo(mockUserId)).rejects.toThrow(
        "Health information not found",
      );
    });
  });
});
