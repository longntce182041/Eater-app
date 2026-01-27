const mongoose = require("mongoose");
const { DietType } = require("../../models/diet_types");
const { DietaryReferences } = require("../../models/dietary_references");
const User = require("../../models/User");
const { User_Profile } = require("../../models/User_Profile");

async function getUserDietaryReferences(userId) {
  return DietaryReferences.findOne({
    userId: new mongoose.Types.ObjectId(userId),
  }).populate("diet_typeId");
}

async function getAllDietTypes() {
  return DietType.find();
}

async function setDietTypeForUser(userId, dietTypeId) {
  let dietaryReferences = await DietaryReferences.findOne({
    userId: new mongoose.Types.ObjectId(userId),
  });
  if (!dietaryReferences) {
    dietaryReferences = new DietaryReferences({
      userId: new mongoose.Types.ObjectId(userId),
      diet_typeId: dietTypeId,
    });
  } else {
    dietaryReferences.diet_typeId = dietTypeId;
  }
  return dietaryReferences.save();
}

async function setUserProfile(userId, profileData) {
  // Remove userId from profileData if it exists (use the one from JWT token)
  const { userId: _, ...cleanProfileData } = profileData;

  let userProfile = await User_Profile.findOne({
    userId: new mongoose.Types.ObjectId(userId),
  });
  if (!userProfile) {
    userProfile = new User_Profile({
      userId: new mongoose.Types.ObjectId(userId),
      ...cleanProfileData,
    });
  } else {
    Object.assign(userProfile, cleanProfileData);
  }
  return userProfile.save();
}

async function setDietaryReference(userId, dietaryData) {
  let dietaryReferences = await DietaryReferences.findOne({
    userId: new mongoose.Types.ObjectId(userId),
    diet_typeId: dietaryData.diet_typeId,
  });
  if (!dietaryReferences) {
    dietaryReferences = new DietaryReferences({
      userId: new mongoose.Types.ObjectId(userId),
      ...dietaryData,
    });
  } else {
    Object.assign(dietaryReferences, dietaryData);
  }
  return dietaryReferences.save();
}

module.exports = {
  getUserDietaryReferences,
  getAllDietTypes,
  setDietTypeForUser,
  setUserProfile,
  setDietaryReference,
};
