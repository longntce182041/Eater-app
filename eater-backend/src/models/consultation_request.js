const mongoose = require("mongoose");

const ConsultationRequestSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Users",
      required: true,
    },
    nutritionistId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Nutritionist",
      default: null,
    },
    title: {
      type: String,
      required: true,
      trim: true,
      maxlength: 200,
    },
    message: {
      type: String,
      required: true,
      trim: true,
      maxlength: 2000,
    },
    category: {
      type: String,
      enum: ["diet", "weight", "health_goal", "meal_plan", "other"],
      required: true,
    },
    attachedMealPlanId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "MealPlan",
      default: null,
    },
    status: {
      type: String,
      enum: ["pending", "accepted", "answered", "closed"],
      default: "pending",
    },
  },
  { timestamps: true }
);

const ConsultationRequest = mongoose.model(
  "ConsultationRequest",
  ConsultationRequestSchema
);

module.exports = { ConsultationRequest };
