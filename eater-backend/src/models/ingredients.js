const mongoose = require("mongoose");

const IngredientSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, unique: true },
    ImageUrl: { type: String },
    calories_per_unit: { type: Number, required: true },
    protein: { type: Number },
    carbs: { type: Number },
    fats: { type: Number },
    description: { type: String },
    unit: { type: String, required: true },
  },
  { timestamps: true },
);

const Ingredient = mongoose.model("Ingredient", IngredientSchema);

module.exports = { Ingredient };
s;
