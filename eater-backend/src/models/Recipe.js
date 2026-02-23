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

// Indexes for performance optimization
Recipes.index({ name: 'text', description: 'text' }); // Full-text search
Recipes.index({ status: 1, createdAt: -1 }); // Filter + Sort optimization
Recipes.index({ cookingTime: 1 }); // Cooking time filter

const Recipe = mongoose.model("Recipe", Recipes);

module.exports = { Recipe };
