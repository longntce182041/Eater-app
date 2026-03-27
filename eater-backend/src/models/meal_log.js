const mongoose = require("mongoose");

const MealLogSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Users",
      required: true,
    },
    mealPlanId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "MealPlans",
      required: false,
    },
    mealPlanItemId: {
      type: String,
      required: false,
    },
    mealName: {
      type: String,
      required: true,
    },
    mealType: {
      type: String,
      enum: ["breakfast", "lunch", "dinner", "snack"],
      required: true,
    },
    calories: {
      type: Number,
      required: true,
    },
    protein: {
      type: Number,
      required: false,
      default: 0,
    },
    carbs: {
      type: Number,
      required: false,
      default: 0,
    },
    fats: {
      type: Number,
      required: false,
      default: 0,
    },
    quantity: {
      type: Number,
      required: true,
    },
    unit: {
      type: String,
      required: true, // grams, ml, pieces, servings, etc
    },
    notes: {
      type: String,
      required: false,
    },
    imageUrl: {
      type: String,
      required: false,
    },
    loggedAt: {
      type: Date,
      required: true,
      index: true,
    },
  },
  { timestamps: true },
);

// Create index on userId and loggedAt for efficient date-based queries
MealLogSchema.index({ userId: 1, loggedAt: -1 });

const MealLog = mongoose.model("MealLogs", MealLogSchema);

module.exports = MealLog;
