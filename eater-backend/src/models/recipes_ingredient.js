const mongoose = require("mongoose");

const RecipesIngredientSchema = new mongoose.Schema(
  {
    recipeId: {
      type: String,
      ref: "Recipe",
      required: true,
    },
    ingredientId: {
      type: String,
      ref: "Ingredient",
      required: true,
    },
    base_quantity: { type: String, required: true },
    unit: { type: String, required: true },
  },
  { timestamps: true },
);

const RecipesIngredient = mongoose.model(
  "RecipesIngredient",
  RecipesIngredientSchema,
);

module.exports = { RecipesIngredient };
