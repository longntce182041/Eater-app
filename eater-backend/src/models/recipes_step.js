const mongoose = require("mongoose");

const RecipesStepSchema = new mongoose.Schema(
  {
    recipeId: {
      type: String,
      ref: "Recipe",
      required: true,
    },
    stepNumber: { type: Number, required: true },
    instruction: { type: String, required: true },
  },
  { timestamps: true },
);

const RecipesStep = mongoose.model("RecipesStep", RecipesStepSchema);

module.exports = { RecipesStep };
