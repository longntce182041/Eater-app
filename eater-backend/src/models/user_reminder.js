const mongoose = require("mongoose");

const userReminderSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Users",
      required: true,
    },
    mealType: {
      type: String,
      enum: ["breakfast", "lunch", "dinner", "snack"],
      required: true,
    },
    // Time in "HH:mm" format (24-hour), e.g. "07:30"
    time: {
      type: String,
      required: true,
      match: /^([01]\d|2[0-3]):([0-5]\d)$/,
    },
    // Days of week: 0=Sunday, 1=Monday, ..., 6=Saturday
    days: {
      type: [Number],
      default: [1, 2, 3, 4, 5, 6, 0],
    },
    enabled: {
      type: Boolean,
      default: true,
    },
    label: {
      type: String,
      maxlength: 100,
    },
  },
  { timestamps: true }
);

// One reminder per meal type per user
userReminderSchema.index({ userId: 1, mealType: 1 }, { unique: true });

const UserReminder = mongoose.model("UserReminder", userReminderSchema);

module.exports = { UserReminder };
