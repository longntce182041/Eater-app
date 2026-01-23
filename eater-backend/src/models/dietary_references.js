const mongoose = require("mongoose");

const DietaryReferencesSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    diet_typeId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "DietType",
      required: true,
    },
    allergies: { type: [String], default: [] },
    dislikesIngredients: { type: [String], default: [] },
  },
  { timestamps: true },
);

const DietaryReferences = mongoose.model(
  "DietaryReferences",
  DietaryReferencesSchema,
);

module.exports = { DietaryReferences };
