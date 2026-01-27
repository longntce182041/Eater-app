const mongoose = require("mongoose");

const DietaryReferencesSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Users",
      required: true,
    },
    diet_typeId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "DietType",
      required: true,
    },
    allergies: { type: [String], default: [] },
    dislikesIngredients: { type: [String], default: [] },
    activityLevel: {
      type: String,
      enum: ["sedentary", "light", "moderate", "active", "very active"],
      required: true,
    },

    cookingSkillLevel: {
      type: String,
      enum: ["beginner", "intermediate", "advanced"],
      default: "beginner",
    },
    available_cooking_time: { type: Number, default: 30 }, // in minutes
    daily_calorie_target: { type: Number, default: 2000 }, // in kcal
  },

  { timestamps: true },
);

const DietaryReferences = mongoose.model(
  "DietaryReferences",
  DietaryReferencesSchema,
);

module.exports = { DietaryReferences };
