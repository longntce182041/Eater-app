const mongoose = require('mongoose');

const HealthGuideSchema = new mongoose.Schema(
  {
    category: {
      type: String,
      enum: ['fasting', 'workouts', 'nutrition', 'meal_prep', 'emotional_eating', 'hydration', 'stress_management'],
      required: true,
      index: true,
    },
    title: {
      type: String,
      required: true,
    },
    description: {
      type: String,
      required: true,
    },
    content: {
      type: String,
      required: true,
    },
    icon: {
      type: String,
      default: 'auto',
    },
    order: {
      type: Number,
      default: 0,
    },
    difficulty: {
      type: String,
      enum: ['beginner', 'intermediate', 'advanced'],
      default: 'beginner',
    },
    estimatedReadTime: {
      type: Number,
      default: 5, // minutes
    },
    tags: {
      type: [String],
      default: [],
    },
    isActive: {
      type: Boolean,
      default: true,
    },
  },
  { timestamps: true }
);

// Indexes for efficient queries
HealthGuideSchema.index({ category: 1, isActive: 1, order: 1 });
HealthGuideSchema.index({ isActive: 1 });

const HealthGuide = mongoose.model("HealthGuide", HealthGuideSchema);

module.exports = { HealthGuide };
