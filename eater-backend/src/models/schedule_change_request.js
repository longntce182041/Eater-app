const mongoose = require("mongoose");

const ScheduleChangeRequestSchema = new mongoose.Schema(
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
    scheduleId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "NutritionistSchedule",
      required: true,
    },
    requestType: {
      type: String,
      enum: ["modify_hours", "take_day_off", "vacation", "special_request"],
      required: true,
    },
    affectedDates: {
      startDate: {
        type: Date,
        required: true,
      },
      endDate: {
        type: Date,
      },
    },
    proposedChanges: {
      date: String,
      dayOfWeek: String,
      startTime: String,
      endTime: String,
      reason: String,
    },
    status: {
      type: String,
      enum: ["pending", "approved", "rejected"],
      default: "pending",
    },
    reason: {
      type: String,
      required: true,
    },
    adminNotes: String,
    approvedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Users",
    },
    approvedAt: Date,
    rejectedAt: Date,
  },
  { timestamps: true }
);

const ScheduleChangeRequest = mongoose.model(
  "ScheduleChangeRequest",
  ScheduleChangeRequestSchema
);

module.exports = { ScheduleChangeRequest };
