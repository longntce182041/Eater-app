const mongoose = require("mongoose");

const mealPlans = new mongoose.Schema(
  {
    userId: {
      type: String,
      ref: "Users",
      required: true,
    },
    nutritionistId: {
      type: String,
      ref: "Nutritionists",
    },
    date: { type: Date, required: true },
  },
  { timestamps: true },
);

const MealPlan = mongoose.model("MealPlans", mealPlans);

module.exports = { MealPlan };
