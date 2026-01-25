const mongoose = require("mongoose");
const { User_Profile } = require("../../models/User_Profile");
const { DietType } = require("../../models/diet_types");
const { DietaryReferences } = require("../../models/dietary_references");

const healthService = {
  async getHealthInfo(userId) {
    const profile = await User_Profile.findOne({ userId });
    if (!profile) {
      const error = new Error("Health information not found");
      error.status = 404;
      throw error;
    }
    return profile;
  },

  async updateHealthInfo(userId, updateData) {
    const profile = await User_Profile.findOneAndUpdate(
      { userId },
      updateData,
      { new: true, runValidators: true },
    );

    if (!profile) {
      const error = new Error("Health information not found");
      error.status = 404;
      throw error;
    }

    return profile;
  },

  async createHealthInfo(userId, healthData) {
    // Check if profile already exists
    const existing = await User_Profile.findOne({
      userId,
    });
    if (existing) {
      const error = new Error(
        "Health information already exists for this user",
      );
      error.status = 400;
      throw error;
    }

    const profile = new User_Profile({
      userId,
      ...healthData,
    });

    await profile.save();
    return profile;
  },

  async deleteHealthInfo(userId) {
    const profile = await User_Profile.findOneAndDelete({
      userId,
    });
    if (!profile) {
      const error = new Error("Health information not found");
      error.status = 404;
      throw error;
    }
    return profile;
  },

  async setDietaryPreferences(userId, dietTypeId, preferences) {
    // Ensure the requested diet type exists
    const dietType = await DietType.findById(dietTypeId);
    if (!dietType) {
      const error = new Error("Diet type not found");
      error.status = 404;
      throw error;
    }

    // Update the user's dietary preferences on their profile
    const profile = await User_Profile.findOneAndUpdate(
      { userId },
      { dietaryPreferences: preferences },
      { new: true, runValidators: true },
    );

    if (!profile) {
      const error = new Error("Health information not found");
      error.status = 404;
      throw error;
    }

    // Upsert into dietary_references to link user to the chosen diet type
    const dietaryReference = await DietaryReferences.findOneAndUpdate(
      { userId },
      { dietTypeId: dietTypeId },
      {
        new: true,
        upsert: true,
        runValidators: true,
        setDefaultsOnInsert: true,
      },
    );

    return { profile, dietaryReference };
  },

  async getDietTypes() {
    const dietTypes = await DietType.find();
    return dietTypes || [];
  },

  async setDietType(userId, dietTypeId) {
    const dietType = await DietType.findById(dietTypeId);
    if (!dietType) {
      const error = new Error("Diet type not found");
      error.status = 404;
      throw error;
    }

    const profile = await User_Profile.findOneAndUpdate(
      { userId },
      { dietType: dietTypeId },
      { new: true, runValidators: true },
    );

    if (!profile) {
      const error = new Error("Health information not found");
      error.status = 404;
      throw error;
    }

    return profile;
  },

  async setHealthGoals(userId, goals) {
    const profile = await User_Profile.findOneAndUpdate(
      { userId },
      { healthGoals: goals },
      { new: true, runValidators: true },
    );

    if (!profile) {
      const error = new Error("Health information not found");
      error.status = 404;
      throw error;
    }

    return profile;
  },

  async setAllergies(userId, allergies) {
    const profile = await User_Profile.findOneAndUpdate(
      { userId },
      { allergies },
      { new: true, runValidators: true },
    );

    if (!profile) {
      const error = new Error("Health information not found");
      error.status = 404;
      throw error;
    }

    return profile;
  },

  async setDislikesIngredients(userId, dislikes) {
    const profile = await User_Profile.findOneAndUpdate(
      { userId },
      { dislikes },
      { new: true, runValidators: true },
    );

    if (!profile) {
      const error = new Error("Health information not found");
      error.status = 404;
      throw error;
    }

    return profile;
  },
};

module.exports = healthService;
