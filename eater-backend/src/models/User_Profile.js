const mongoose = require("mongoose");

const User_ProfileSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Users",
      required: true,
    },
    firstName: { type: String, default: "" },
    lastName: { type: String, default: "" },
    phoneNumber: { type: String, default: "" },
    age: { type: Number, required: true },
    gender: { type: String, enum: ["male", "female", "other"], required: true },
    height: { type: Number, required: true }, // in centimeters
    weight: { type: Number, required: true }, // in kilograms
    goal_weight: { type: Number, default: null }, // in kilograms
    healthGoals: { type: String, default: "" }, // e.g., 'weight loss', 'muscle gain'
  },
  { timestamps: true },
);

const User_Profile = mongoose.model("User_Profiles", User_ProfileSchema);

module.exports = { User_Profile };
