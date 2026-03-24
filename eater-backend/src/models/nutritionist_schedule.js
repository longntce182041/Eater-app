const mongoose = require("mongoose");

const NutritionistScheduleSchema = new mongoose.Schema(
  {
    nutritionistId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Users",
      required: true,
    },
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Users",
      required: true,
    },
    // Work days with specific dates (not weekdays)
    workDays: [
      {
        date: {
          type: String, // Format: YYYY-MM-DD (e.g., "2026-03-25")
          required: true,
        },
        startTime: {
          type: String, // HH:MM format (e.g., "09:00")
          required: true,
        },
        endTime: {
          type: String, // HH:MM format (e.g., "17:00")
          required: true,
        },
        isAvailable: {
          type: Boolean,
          default: true,
        },
      },
    ],
    // Special days (vacations, holidays, off days, etc.)
    specialDays: [
      {
        date: {
          type: String, // Format: YYYY-MM-DD
          required: true,
        },
        type: {
          type: String,
          enum: ["vacation", "holiday", "off", "special_event"],
          default: "off",
        },
        reason: String,
        isAvailable: {
          type: Boolean,
          default: false,
        },
      },
    ],
    status: {
      type: String,
      enum: ["active", "inactive", "on_leave"],
      default: "active",
    },
  },
  { timestamps: true }
);

const NutritionistSchedule = mongoose.model(
  "NutritionistSchedule",
  NutritionistScheduleSchema
);

module.exports = { NutritionistSchedule };
