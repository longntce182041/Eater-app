const mongoose = require("mongoose");

const recipesMicronutrientValuesSchema = new mongoose.Schema(
  {
    recipeId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Recipe",
      required: true,
    },
    micronutrientId: {
      type: mongoose.Schema.Types.ObjectId,
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
