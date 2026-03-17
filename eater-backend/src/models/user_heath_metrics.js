const mongoose = require("mongoose");

const userHealthMetricsSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: "Users", required: true },
  bmi: { type: Number, required: true },
  bmr: { type: Number, required: true },
  tdee: { type: Number, required: true },
  body_category: {
    type: String,
    required: true,
  },
  calculatedAt: { type: Date, default: Date.now },
  source: {
    type: String,
    required: true,
    enum: ["AI", "Nutritionist"],
  },
});

const UserHealthMetrics = mongoose.model(
  "UserHealthMetrics",
  userHealthMetricsSchema,
);

module.exports = { UserHealthMetrics };
