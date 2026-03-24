const mongoose = require("mongoose");

const favoriteRecipeSchema = new mongoose.Schema(
    {
        userId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Users",
            required: true,
        },
        recipeId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Recipe",
            required: true,
        },
    },
    { timestamps: true },
);

// Compound index to ensure one user can only favorite a recipe once
favoriteRecipeSchema.index({ userId: 1, recipeId: 1 }, { unique: true });

// Index for quick lookup of user's favorites
favoriteRecipeSchema.index({ userId: 1, createdAt: -1 });

const FavoriteRecipe = mongoose.model("FavoriteRecipe", favoriteRecipeSchema);

module.exports = { FavoriteRecipe };
