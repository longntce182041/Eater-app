const mongoose = require("mongoose");

const RecipesReviewSchema = new mongoose.Schema(
  {
    userId: {
      type: String,
      ref: "User",
      required: true,
    },
    recipeId: {
      type: String,
      ref: "Recipe",
      required: true,
    },
    rating: { type: Number, required: true, min: 1, max: 5 },
    comment: { type: String, default: "" },
  },
  { timestamps: true },
);

const RecipesReview = mongoose.model("RecipesReview", RecipesReviewSchema);

module.exports = { RecipesReview };
