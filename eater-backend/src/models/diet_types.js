const mongoose = require("mongoose");

const DietTypesSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, unique: true },
    carb_ratio: { type: Number, required: true }, // percentage of carbs
    protein_ratio: { type: Number, required: true }, // percentage of proteins
    fat_ratio: { type: Number, required: true }, // percentage of fats
    description: { type: String, required: true },
    source: { type: String },
  },
  { timestamps: true },
);

const DietType = mongoose.model("DietType", DietTypesSchema);

module.exports = { DietType };
