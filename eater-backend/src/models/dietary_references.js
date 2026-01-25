const mongoose = require("mongoose");

const DietaryReferencesSchema = new mongoose.Schema(
  {
    userId: {
      type: String,
      ref: "User",
      required: true,
    },
    diet_typeId: {
      type: String,
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
