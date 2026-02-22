const mongoose = require("mongoose");

const mealPlans = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    nutritionistId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Nutritionist",
    },
    date: { type: Date, required: true },
    days: { type: Number, default: 1 },
    targetCalories: { type: Number },
    actualCalories: { type: Number },
    dietTypes: [{ type: String }],
    healthGoal: { type: String },
    status: {
      type: String,
      enum: ["active", "completed", "cancelled"],
      default: "active",
    },
    aiGenerated: { type: Boolean, default: false },
    metadata: { type: mongoose.Schema.Types.Mixed },
  },
  { timestamps: true },
);

const MealPlan = mongoose.model("MealPlan", mealPlans);

module.exports = { MealPlan };
