const mongoose = require("mongoose");

const recipesMicronutrientValuesSchema = new mongoose.Schema(
  {
    recipeId: {
      type: String,
      ref: "Recipe",
      required: true,
    },
    micronutrientId: {
      type: String,
      ref: "Micronutrient",
      required: true,
    },
    amount: { type: Number, required: true },
  },
  { timestamps: true },
);
const RecipeMicronutrientValues = mongoose.model(
  "RecipeMicronutrientValues",
  recipesMicronutrientValuesSchema,
);

module.exports = { RecipeMicronutrientValues };
