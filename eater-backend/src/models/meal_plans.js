const mongoose = require("mongoose");

const mealPlans = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Users",
      required: true,
    },
    nutritionistId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Nutritionists",
    },
    date: { type: Date, required: true },
  },
  { timestamps: true },
);

const MealPlan = mongoose.model("MealPlans", mealPlans);

module.exports = { MealPlan };
