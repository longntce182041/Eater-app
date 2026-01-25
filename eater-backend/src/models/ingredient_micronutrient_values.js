const mongoose = require("mongoose");

const ingredientMicronutrientValuesSchema = new mongoose.Schema(
  {
    ingredientId: {
      type: String,
      ref: "Ingredient",
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
const IngredientMicronutrientValues = mongoose.model(
  "IngredientMicronutrientValues",
  ingredientMicronutrientValuesSchema,
);

module.exports = { IngredientMicronutrientValues };
