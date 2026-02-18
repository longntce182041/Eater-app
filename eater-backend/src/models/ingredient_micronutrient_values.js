const mongoose = require("mongoose");

const ingredientMicronutrientValuesSchema = new mongoose.Schema(
  {
    ingredientId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Ingredient",
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
const IngredientMicronutrientValues = mongoose.model(
  "IngredientMicronutrientValue",
  ingredientMicronutrientValuesSchema,
);

module.exports = { IngredientMicronutrientValues };
