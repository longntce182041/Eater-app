const { GroceryItem } = require("../../models/grocery_item");
const { ingredients } = require("../../models/ingredients");

/**
 * Add ingredients to user's grocery list
 */
async function addGroceryItems(userId, ingredientsList) {
    // ingredientsList: [{ ingredientId, ingredientName, quantity, unit, category }, ...]

    if (!Array.isArray(ingredientsList) || ingredientsList.length === 0) {
        throw new Error("Invalid ingredients list");
    }

    const recipeIdsToAdd = [
        ...new Set(
            ingredientsList
                .map((item) => item.recipeId)
                .filter((recipeId) => !!recipeId)
                .map((recipeId) => recipeId.toString())
        ),
    ];

    if (recipeIdsToAdd.length > 0) {
        const existingPendingCount = await GroceryItem.countDocuments({
            userId,
            isPurchased: false,
            recipeId: { $in: recipeIdsToAdd },
        });

        if (existingPendingCount > 0) {
            const error = new Error(
                "This recipe still has pending grocery items. Please mark them as purchased or remove them before adding this recipe again."
            );
            error.statusCode = 409;
            error.code = "RECIPE_PENDING_ITEMS_EXIST";
            throw error;
        }
    }

    const items = ingredientsList.map((item) => ({
        userId,
        ingredientId: item.ingredientId,
        ingredientName: item.ingredientName,
        quantity: item.quantity,
        unit: item.unit,
        recipeId: item.recipeId || null,
        recipeName: item.recipeName || null,
        category: item.category || "Other",
        isPurchased: false,
    }));

    const createdItems = await GroceryItem.insertMany(items);
    return createdItems;
}

/**
 * Get user's grocery list
 */
async function getUserGroceryList(userId, options = { page: 1, limit: 100 }) {
    const { page = 1, limit = 100 } = options;
    const skip = (page - 1) * limit;

    const items = await GroceryItem.find({ userId })
        .sort({ isPurchased: 1, createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .lean();

    const total = await GroceryItem.countDocuments({ userId });

    // Group by category
    const grouped = {};
    items.forEach((item) => {
        if (!grouped[item.category]) {
            grouped[item.category] = [];
        }
        grouped[item.category].push(item);
    });

    return {
        items,
        grouped,
        pagination: {
            total,
            page,
            limit,
            totalPages: Math.ceil(total / limit),
        },
    };
}

/**
 * Toggle purchased status of a grocery item
 */
async function toggleGroceryItemStatus(itemId, userId) {
    const item = await GroceryItem.findById(itemId);

    if (!item) {
        throw new Error("Grocery item not found");
    }

    // Verify ownership
    if (item.userId.toString() !== userId.toString()) {
        throw new Error("Not authorized to update this item");
    }

    item.isPurchased = !item.isPurchased;
    item.purchasedAt = item.isPurchased ? new Date() : null;
    await item.save();

    return item;
}

/**
 * Remove a grocery item
 */
async function removeGroceryItem(itemId, userId) {
    const item = await GroceryItem.findById(itemId);

    if (!item) {
        throw new Error("Grocery item not found");
    }

    // Verify ownership
    if (item.userId.toString() !== userId.toString()) {
        throw new Error("Not authorized to delete this item");
    }

    await GroceryItem.findByIdAndDelete(itemId);
    return item;
}

/**
 * Clear all purchased items for a user
 */
async function clearPurchasedItems(userId) {
    const result = await GroceryItem.deleteMany({
        userId,
        isPurchased: true,
    });

    return result;
}

/**
 * Get grocery stats for user
 */
async function getGroceryStats(userId) {
    const total = await GroceryItem.countDocuments({ userId });
    const purchased = await GroceryItem.countDocuments({
        userId,
        isPurchased: true,
    });
    const pending = total - purchased;

    return {
        total,
        purchased,
        pending,
        percentage: total > 0 ? Math.round((purchased / total) * 100) : 0,
    };
}

/**
 * Check if ingredient already exists in grocery list
 */
async function checkDuplicateIngredient(userId, ingredientId) {
    const existing = await GroceryItem.findOne({
        userId,
        ingredientId,
        isPurchased: false,
    });

    return !!existing;
}

module.exports = {
    addGroceryItems,
    getUserGroceryList,
    toggleGroceryItemStatus,
    removeGroceryItem,
    clearPurchasedItems,
    getGroceryStats,
    checkDuplicateIngredient,
};
