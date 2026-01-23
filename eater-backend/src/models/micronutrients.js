const mongoose = require("mongoose");

const MicronutrientSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, unique: true },
    unit: { type: String, required: true },
    description: { type: String },
  },
  { timestamps: true },
);

const Micronutrient = mongoose.model("Micronutrient", MicronutrientSchema);
module.exports = { Micronutrient };
