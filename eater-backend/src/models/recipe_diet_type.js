const mongoose = require("mongoose");

const recipesDietTypeSchema = new mongoose.Schema(
  {
    recipeId: {
      type: String,
      ref: "Recipe",
      required: true,
    },
    dietTypeId: {
      type: String,
      ref: "DietType",
      required: true,
    },
  },
  { timestamps: true },
);

const RecipeDietType = mongoose.model("RecipeDietType", recipesDietTypeSchema);

module.exports = { RecipeDietType };
