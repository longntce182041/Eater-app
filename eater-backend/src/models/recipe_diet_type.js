const mongoose = require("mongoose");

const recipesDietTypeSchema = new mongoose.Schema(
  {
    recipeId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Recipe",
      required: true,
    },
    dietTypeId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "DietType",
      required: true,
    },
  },
  { timestamps: true },
);

const RecipeDietType = mongoose.model("RecipeDietType", recipesDietTypeSchema);

module.exports = { RecipeDietType };
