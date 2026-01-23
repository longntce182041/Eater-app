const mongoose = require("mongoose");

const Recipes = new mongoose.Schema(
  {
    name: { type: String, required: true },
    description: { type: String, required: true },
    imageUrl: { type: String },
    cookingTime: { type: Number, required: true }, // in minutes
    baseServings: { type: Number, required: true }, // in grams
    status: { type: String, enum: ["draft", "published"], default: "draft" },
  },
  { timestamps: true },
);

const Recipe = mongoose.model("Recipe", Recipes);

module.exports = { Recipe };
