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
  },
  { timestamps: true },
);

const MealPlan = mongoose.model("MealPlan", mealPlans);

module.exports = { MealPlan };
