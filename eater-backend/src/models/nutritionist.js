const { verify } = require("jsonwebtoken");
const mongoose = require("mongoose");
const NutritionstistSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Users",
      required: true,
    },
    fullName: { type: String, required: true },
    specialization: { type: String, required: true },
    experience: { type: Number, required: true }, // in years
    certifications_url: { type: [String], default: [] },
    verified: { type: Boolean, default: false },
  },
  { timestamps: true },
);
const Nutritionist = mongoose.model("Nutritionists", NutritionstistSchema);
module.exports = { Nutritionist };
