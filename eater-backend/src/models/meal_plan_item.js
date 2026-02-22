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
    servings: {
      type: Number,
      required: true,
      default: 1,
    },
    calories: {
      type: Number,
      required: true,
    },
    protein: {
      type: Number,
      default: 0,
    },
    carbohydrates: {
      type: Number,
      default: 0,
    },
    fat: {
      type: Number,
      default: 0,
    },
  },
  { timestamps: true },
);

const MealPlanItem = mongoose.model("MealPlanItem", mealPlanItemSchema);

module.exports = { MealPlanItem };
