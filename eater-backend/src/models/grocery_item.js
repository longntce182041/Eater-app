const mongoose = require("mongoose");

const GroceryItemSchema = new mongoose.Schema(
    {
        userId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Users",
            required: true,
        },
        ingredientId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "ingredients",
            required: true,
        },
        ingredientName: { type: String, required: true },
        quantity: { type: Number, required: true },
        unit: { type: String, required: true }, // ml, g, unit, tbsp, etc
        recipeId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Recipes",
            required: false,
            default: null,
        },
        recipeName: { type: String, default: null },
        isPurchased: { type: Boolean, default: false },
        category: { type: String, default: "Other" }, // Water, Nuts, Dairy, Meat, Vegetables, etc
        addedAt: { type: Date, default: Date.now },
        purchasedAt: { type: Date, default: null },
    },
    { timestamps: true }
);

// Index for better query performance
GroceryItemSchema.index({ userId: 1, createdAt: -1 });
GroceryItemSchema.index({ userId: 1, isPurchased: 1 });

const GroceryItem = mongoose.model("GroceryItems", GroceryItemSchema);

module.exports = { GroceryItem };
