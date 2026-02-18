const mongoose = require("mongoose");
const profileRepository = require("../repositories/profile.repository");
const userRepository = require("../repositories/user.repository");
const { AppError } = require("../../utils/errors");
const { DietaryReferences } = require("../../models/dietary_references");

// Helper to pick only allowed fields from input
function pickFields(source, allowed) {
  if (!source || typeof source !== "object") return {};
  const picked = {};
  for (const key of allowed) {
    if (Object.prototype.hasOwnProperty.call(source, key)) {
      picked[key] = source[key];
    }
  }
  return picked;
}

// Get user profile
async function getProfile(userId) {
  // Verify user exists
  const user = await userRepository.findById(userId);
  if (!user) {
    throw new AppError("User not found", 404);
  }

  // Get profile
  const profile = await profileRepository.getProfileByUserId(userId);
  if (!profile) {
    throw new AppError(
      "User profile not found. Please complete your profile setup.",
      404,
    );
  }

  // Also fetch dietary references (optional)
  const dietaryReferences = await DietaryReferences.findOne({
    userId: new mongoose.Types.ObjectId(userId),
  }).populate("diet_typeId");

  return {
    profile,
    dietaryReferences,
  };
}

// Create user profile (for new users)
async function createProfile(userId, profileData) {
  // Verify user exists
  const user = await userRepository.findById(userId);
  if (!user) {
    throw new AppError("User not found", 404);
  }

  // Check if profile already exists
  const existingProfile = await profileRepository.profileExists(userId);
  if (existingProfile) {
    throw new AppError("User profile already exists", 409);
  }

  // Create new profile
  const profile = await profileRepository.createProfile({
    userId,
    ...profileData,
  });

  return {
    message: "Profile created successfully",
    profile,
  };
}

// Update user profile
async function updateProfile(userId, updateData) {
  // Verify user exists
  const user = await userRepository.findById(userId);
  if (!user) {
    throw new AppError("User not found", 404);
  }

  // Check if profile exists
  const existingProfile = await profileRepository.profileExists(userId);
  if (!existingProfile) {
    throw new AppError(
      "User profile not found. Please complete your profile setup first.",
      404,
    );
  }

  // Split incoming data into User_Profile fields vs DietaryReferences fields
  const profileFields = [
    "firstName",
    "lastName",
    "phoneNumber",
    "avatar",
    "age",
    "gender",
    "height",
    "weight",
    "goal_weight",
    "healthGoals",
  ];
  const dietaryFields = [
    "diet_typeId",
    "allergies",
    "dislikesIngredients",
    "activityLevel",
    "cookingSkillLevel",
    "available_cooking_time",
    "daily_calorie_target",
  ];

  const profileUpdate = pickFields(updateData, profileFields);
  const dietaryUpdate = pickFields(updateData, dietaryFields);

  // Update User_Profile
  const profile = Object.keys(profileUpdate).length
    ? await profileRepository.updateProfile(userId, profileUpdate)
    : await profileRepository.getProfileByUserId(userId);

  // Update DietaryReferences (upsert if diet_typeId provided)
  let dietaryReferences = await DietaryReferences.findOne({
    userId: new mongoose.Types.ObjectId(userId),
  });

  if (Object.keys(dietaryUpdate).length) {
    if (!dietaryReferences) {
      if (!dietaryUpdate.diet_typeId) {
        // Cannot create without required diet_typeId
        throw new AppError(
          "Dietary references not found. Provide 'diet_typeId' to create a new record.",
          404,
        );
      }
      dietaryReferences = new DietaryReferences({
        userId: new mongoose.Types.ObjectId(userId),
        ...dietaryUpdate,
      });
    } else {
      Object.assign(dietaryReferences, dietaryUpdate);
    }
    await dietaryReferences.save();
    // Populate diet type for response consistency
    dietaryReferences = await DietaryReferences.findById(
      dietaryReferences._id,
    ).populate("diet_typeId");
  }

  return {
    message: "Profile updated successfully",
    profile,
    dietaryReferences,
  };
}

module.exports = {
  getProfile,
  createProfile,
  updateProfile,
};
