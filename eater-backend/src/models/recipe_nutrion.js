const mongoose = require("mongoose");

const recipeNutrionSchema = new mongoose.Schema(
  {
    recipeId: {
      type: String,
      ref: "Recipe",
      required: true,
    },
    calories: { type: Number, required: true },
    protein: { type: Number, required: true },
    fat: { type: Number, required: true },
    carbohydrates: { type: Number, required: true },
  },
  { timestamps: true },
);

const RecipeNutrition = mongoose.model("RecipeNutrition", recipeNutrionSchema);

module.exports = { RecipeNutrition };
