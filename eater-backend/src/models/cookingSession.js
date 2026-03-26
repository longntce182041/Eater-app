const mongoose = require("mongoose");

const CookingSessionSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    recipeId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Recipe",
      required: true,
    },
    // Session metadata
    status: {
      type: String,
      enum: ["active", "paused", "completed", "abandoned"],
      default: "active",
    },
    startTime: {
      type: Date,
      default: Date.now,
    },
    endTime: {
      type: Date,
    },
    pausedTime: {
      type: Date, // When session was paused
    },
    // Progress tracking
    currentStepIndex: {
      type: Number,
      default: 0,
    },
    completedSteps: [
      {
        stepNumber: Number,
        completedAt: {
          type: Date,
          default: Date.now,
        },
        duration: Number, // seconds spent on this step
        notes: String, // optional user notes
      },
    ],
    // Stats
    totalDuration: Number, // seconds (calculated on completion)
    servings: {
      type: Number,
      required: true,
    },
    // Device info (for analytics)
    deviceInfo: {
      platform: String, // ios/android
      screenSize: String,
      locale: String,
    },
  },
  { timestamps: true }
);

// Indexes for efficient queries
CookingSessionSchema.index({ userId: 1, createdAt: -1 });
CookingSessionSchema.index({ recipeId: 1, status: 1 });
CookingSessionSchema.index({ status: 1 }); // For finding active sessions

const CookingSession = mongoose.model("CookingSession", CookingSessionSchema);

module.exports = { CookingSession };
