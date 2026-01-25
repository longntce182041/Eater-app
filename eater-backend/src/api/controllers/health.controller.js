const healthService = require("../services/health.service");

const healthController = {
  async getHealthInfo(req, res, next) {
    try {
      const { userId } = req.params;
      const profile = await healthService.getHealthInfo(userId);

      return res.status(200).json({
        status: "success",
        data: profile,
      });
    } catch (err) {
      return next(err);
    }
  },

  async updateHealthInfo(req, res, next) {
    try {
      const { userId } = req.params;
      const updateData = req.body;

      const profile = await healthService.updateHealthInfo(userId, updateData);

      return res.status(200).json({
        status: "success",
        message: "Health information updated successfully",
        data: profile,
      });
    } catch (err) {
      return next(err);
    }
  },

  async createHealthInfo(req, res, next) {
    try {
      const { userId } = req.params;
      const healthData = req.body;

      const profile = await healthService.createHealthInfo(userId, healthData);

      return res.status(201).json({
        status: "success",
        message: "Health information created successfully",
        data: profile,
      });
    } catch (err) {
      return next(err);
    }
  },

  async deleteHealthInfo(req, res, next) {
    try {
      const { userId } = req.params;

      await healthService.deleteHealthInfo(userId);

      return res.status(204).send();
    } catch (err) {
      return next(err);
    }
  },
  async getDietTypes(req, res, next) {
    try {
      const dietTypes = await healthService.getDietTypes();
      return res.status(200).json({
        status: "success",
        data: dietTypes,
      });
    } catch (err) {
      return next(err);
    }
  },
  async setDietType(req, res, next) {
    try {
      const { userId } = req.params;
      const { dietTypeId } = req.body;

      const profile = await healthService.setDietType(userId, dietTypeId);

      return res.status(200).json({
        status: "success",
        message: "Diet type updated successfully",
        data: profile,
      });
    } catch (err) {
      return next(err);
    }
  },
  async setDietaryPreferences(req, res, next) {
    try {
      const { userId } = req.params;
      const { dietTypeId, preferences } = req.body;

      const { profile, dietaryReference } =
        await healthService.setDietaryPreferences(
          userId,
          dietTypeId,
          preferences,
        );

      return res.status(200).json({
        status: "success",
        message: "Dietary preferences updated successfully",
        data: profile,
        dietaryReference,
      });
    } catch (err) {
      return next(err);
    }
  },
  async setHealthGoals(req, res, next) {
    try {
      const { userId } = req.params;
      const { goals } = req.body;

      const profile = await healthService.setHealthGoals(userId, goals);

      return res.status(200).json({
        status: "success",
        message: "Health goals updated successfully",
        data: profile,
      });
    } catch (err) {
      return next(err);
    }
  },
  async setAllergies(req, res, next) {
    try {
      const { userId } = req.params;
      const { allergies } = req.body;

      const profile = await healthService.setAllergies(userId, allergies);

      return res.status(200).json({
        status: "success",
        message: "Allergies updated successfully",
        data: profile,
      });
    } catch (err) {
      return next(err);
    }
  },
  async setDislikesIngredients(req, res, next) {
    try {
      const { userId } = req.params;
      const { dislikes } = req.body;

      const profile = await healthService.setDislikesIngredients(
        userId,
        dislikes,
      );

      return res.status(200).json({
        status: "success",
        message: "Disliked ingredients updated successfully",
        data: profile,
      });
    } catch (err) {
      return next(err);
    }
  },
};

module.exports = healthController;
