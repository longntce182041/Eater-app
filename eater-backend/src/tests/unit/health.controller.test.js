const mongoose = require("mongoose");
const healthController = require("../../api/controllers/health.controller");
const healthService = require("../../api/services/health.service");

// Mock the service
jest.mock("../../api/services/health.service");

describe("Health Controller", () => {
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
  };

  let req, res, next;

  beforeEach(() => {
    req = {
      params: { userId: mockUserId },
      body: {},
    };

    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn().mockReturnThis(),
      send: jest.fn(),
    };

    next = jest.fn();

    jest.clearAllMocks();
  });

  describe("getHealthInfo", () => {
    test("should return health info with status 200", async () => {
      healthService.getHealthInfo.mockResolvedValue(mockHealthData);

      await healthController.getHealthInfo(req, res, next);

      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({
        status: "success",
        data: mockHealthData,
      });
    });

    test("should call next with error on service failure", async () => {
      const error = new Error("Database error");
      healthService.getHealthInfo.mockRejectedValue(error);

      await healthController.getHealthInfo(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe("updateHealthInfo", () => {
    test("should update and return health info with status 200", async () => {
      const updateData = { weight: 70 };
      const updatedProfile = { ...mockHealthData, ...updateData };

      req.body = updateData;
      healthService.updateHealthInfo.mockResolvedValue(updatedProfile);

      await healthController.updateHealthInfo(req, res, next);

      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith({
        status: "success",
        message: "Health information updated successfully",
        data: updatedProfile,
      });
      expect(healthService.updateHealthInfo).toHaveBeenCalledWith(
        mockUserId,
        updateData,
      );
    });

    test("should handle partial updates", async () => {
      const partialUpdate = { weight: 72, activityLevel: "active" };
      const updatedProfile = { ...mockHealthData, ...partialUpdate };

      req.body = partialUpdate;
      healthService.updateHealthInfo.mockResolvedValue(updatedProfile);

      await healthController.updateHealthInfo(req, res, next);

      expect(healthService.updateHealthInfo).toHaveBeenCalledWith(
        mockUserId,
        partialUpdate,
      );
    });

    test("should call next with error on service failure", async () => {
      const error = new Error("Update failed");
      req.body = { weight: 70 };
      healthService.updateHealthInfo.mockRejectedValue(error);

      await healthController.updateHealthInfo(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe("createHealthInfo", () => {
    test("should create and return health info with status 201", async () => {
      const createData = {
        age: 28,
        gender: "female",
        height: 165,
        weight: 60,
        activityLevel: "moderate",
      };

      req.body = createData;
      healthService.createHealthInfo.mockResolvedValue({
        ...mockHealthData,
        ...createData,
      });

      await healthController.createHealthInfo(req, res, next);

      expect(res.status).toHaveBeenCalledWith(201);
      expect(res.json).toHaveBeenCalledWith(
        expect.objectContaining({
          status: "success",
          message: "Health information created successfully",
        }),
      );
    });

    test("should call next with error if profile already exists", async () => {
      const error = new Error(
        "Health information already exists for this user",
      );
      error.status = 400;
      req.body = mockHealthData;
      healthService.createHealthInfo.mockRejectedValue(error);

      await healthController.createHealthInfo(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe("deleteHealthInfo", () => {
    test("should delete and return 204 status", async () => {
      healthService.deleteHealthInfo.mockResolvedValue(mockHealthData);

      await healthController.deleteHealthInfo(req, res, next);

      expect(res.status).toHaveBeenCalledWith(204);
      expect(res.send).toHaveBeenCalled();
    });

    test("should call next with error on service failure", async () => {
      const error = new Error("Delete failed");
      healthService.deleteHealthInfo.mockRejectedValue(error);

      await healthController.deleteHealthInfo(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });

    test("should call service with correct userId", async () => {
      healthService.deleteHealthInfo.mockResolvedValue(mockHealthData);

      await healthController.deleteHealthInfo(req, res, next);

      expect(healthService.deleteHealthInfo).toHaveBeenCalledWith(mockUserId);
    });
  });
});
