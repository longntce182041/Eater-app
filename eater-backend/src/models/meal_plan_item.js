const mongoose = require("mongoose");

const mealPlanItemSchema = new mongoose.Schema(
  {
    mealPlanId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "MealPlan",
      required: true,
    },
    recipeId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Recipe",
      required: true,
    },
    mealType: {
      type: String,
      enum: ["breakfast", "lunch", "dinner", "snack"],
      required: true,
    },
  },
  { timestamps: true },
);

const MealPlanItem = mongoose.model("MealPlanItem", mealPlanItemSchema);

module.exports = { MealPlanItem };
