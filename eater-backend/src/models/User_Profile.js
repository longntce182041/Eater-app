const mongoose = require("mongoose");

const User_ProfileSchema = new mongoose.Schema(
  {
    userId: {
      type: String,
      ref: "User",
      required: true,
    },
    firstName: { type: String, default: "" },
    lastName: { type: String, default: "" },
    phoneNumber: { type: String, default: "" },
    avatar: { type: String, default: "" }, // URL to avatar image
    age: { type: Number, required: true },
    gender: { type: String, enum: ["male", "female", "other"], required: true },
    height: { type: Number, required: true }, // in centimeters
    weight: { type: Number, required: true }, // in kilograms
    dietaryPreferences: { type: [String], default: [] }, // e.g., ['vegetarian', 'gluten-free']
    allergies: { type: [String], default: [] }, // e.g., ['peanuts', 'shellfish']
    activityLevel: {
      type: String,
      enum: ["sedentary", "light", "moderate", "active", "very active"],
      required: true,
    },
    healthGoals: { type: String, default: "" }, // e.g., 'weight loss', 'muscle gain'
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

const User_Profile = mongoose.model("User_Profiles", User_ProfileSchema);

module.exports = { User_Profile };
