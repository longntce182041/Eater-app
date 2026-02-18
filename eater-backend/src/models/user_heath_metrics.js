const mongoose = require("mongoose");
const userHealthMetricsSchema = {
  userId: { type: String, required: true },
  bmi: { type: Number, required: true },
  bmr: { type: Number, required: true },
  tdee: { type: Number, required: true },
  calculatedAt: { type: Date, default: Date.now },
};

const UserHealthMetrics = mongoose.model(
  "UserHealthMetrics",
  userHealthMetricsSchema,
);

module.exports = { UserHealthMetrics };
