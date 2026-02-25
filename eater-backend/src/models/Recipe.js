const mongoose = require("mongoose");

const Recipes = new mongoose.Schema(
  {
    name: { type: String, required: true },
    description: { type: String, required: true },
    imageUrl: { type: String },
    cookingTime: { type: Number, required: true }, // in minutes
    baseServings: { type: Number, required: true }, // in grams
    status: { type: String, enum: ["draft", "published"], default: "draft" },
    // NEW: For optimization service compatibility
    isPublished: { type: Boolean, default: false },
    rating: { type: Number, min: 0, max: 5, default: 3.5 },
    // NEW: Nutrition info for meal plan optimization
    nutritionInfo: {
      calories: { type: Number, default: 0 },
      protein: { type: Number, default: 0 }, // grams
      carbs: { type: Number, default: 0 }, // grams
      fat: { type: Number, default: 0 }, // grams
      fiber: { type: Number, default: 0 }, // grams
    },
  },
  { timestamps: true },
);

// Indexes for performance optimization
Recipes.index({ name: "text", description: "text" }); // Full-text search
Recipes.index({ status: 1, createdAt: -1 }); // Filter + Sort optimization
Recipes.index({ cookingTime: 1 }); // Cooking time filter
Recipes.index({ isPublished: 1 }); // For published filter
Recipes.index({ "nutritionInfo.calories": 1 }); // For calorie range searches
Recipes.index({ rating: -1 }); // For rating sort

const Recipe = mongoose.model("Recipe", Recipes);

module.exports = { Recipe };
