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
    dayIndex: {
      type: Number,
      default: 0,
      required: true,
    },
    // OPTIMIZATION FIELDS
    userRating: {
      type: Number,
      min: 1,
      max: 5,
      default: null,
    },
    userAction: {
      type: String,
      enum: ["none", "saved", "replaced", "disliked", "completed"],
      default: "none",
    },
    replacedFrom: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Recipe",
      default: null,
    },
    replacementReason: {
      type: String,
      default: null,
    },
    isLocked: {
      type: Boolean,
      default: false, // When true, this meal won't be changed during optimization
    },
  },
  { timestamps: true },
);

const MealPlanItem = mongoose.model("MealPlanItem", mealPlanItemSchema);

module.exports = { MealPlanItem };
