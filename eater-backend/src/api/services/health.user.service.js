const { DietType } = require("../../models/diet_types");
const { DietaryReferences } = require("../../models/dietary_references");

async function getUserDietaryReferences(userId) {
  return DietaryReferences.findOne({ userId }).populate("diet_typeId");
}

async function getAllDietTypes() {
  return DietType.find();
}

async function setDietTypeForUser(userId, dietTypeId) {
  let dietaryReferences = await DietaryReferences.findOne({ userId });
  if (!dietaryReferences) {
    dietaryReferences = new DietaryReferences({
      userId,
      diet_typeId: dietTypeId,
    });
  } else {
    dietaryReferences.diet_typeId = dietTypeId;
  }
  return dietaryReferences.save();
}

module.exports = {
  getUserDietaryReferences,
  getAllDietTypes,
  setDietTypeForUser,
};
