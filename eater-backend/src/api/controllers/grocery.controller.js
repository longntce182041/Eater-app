const groceryService = require("../services/grocery.service");

/**
 * Add ingredients to grocery list
 * POST /api/groceries
 */
exports.addToGroceryList = async (req, res) => {
    try {
        const userId = req.user?.id;
        const { ingredients } = req.body;

        if (!userId) {
            return res.status(401).json({
                success: false,
                message: "Authentication required",
                code: "UNAUTHORIZED",
            });
        }

        if (!Array.isArray(ingredients) || ingredients.length === 0) {
            return res.status(400).json({
                success: false,
                message: "Invalid ingredients array",
                code: "INVALID_INPUT",
            });
        }

        const items = await groceryService.addGroceryItems(userId, ingredients);

        res.status(201).json({
            success: true,
            data: {
                items: items.map((item) => ({
                    id: item._id,
                    ingredientId: item.ingredientId,
                    ingredientName: item.ingredientName,
                    quantity: item.quantity,
                    unit: item.unit,
                    recipeId: item.recipeId,
                    recipeName: item.recipeName,
                    category: item.category,
                    isPurchased: item.isPurchased,
                })),
            },
        });
    } catch (error) {
        console.error("Error adding to grocery list:", error);
        const statusCode = error.statusCode || 500;
        res.status(statusCode).json({
            success: false,
            message: error.message || "Failed to add items",
            code: error.code || "ADD_GROCERY_ERROR",
        });
    }
};

/**
 * Get user's grocery list
 * GET /api/groceries
 */
exports.getGroceryList = async (req, res) => {
    try {
        const userId = req.user?.id;
        const { page = 1, limit = 100 } = req.query;

        if (!userId) {
            return res.status(401).json({
                success: false,
                message: "Authentication required",
                code: "UNAUTHORIZED",
            });
        }

        const result = await groceryService.getUserGroceryList(userId, {
            page: parseInt(page),
            limit: parseInt(limit),
        });

        const stats = await groceryService.getGroceryStats(userId);

        res.status(200).json({
            success: true,
            data: {
                items: result.items.map((item) => ({
                    id: item._id,
                    ingredientId: item.ingredientId,
                    ingredientName: item.ingredientName,
                    quantity: item.quantity,
                    unit: item.unit,
                    recipeId: item.recipeId,
                    recipeName: item.recipeName,
                    category: item.category,
                    isPurchased: item.isPurchased,
                    addedAt: item.addedAt,
                    purchasedAt: item.purchasedAt,
                })),
                grouped: Object.entries(result.grouped).reduce(
                    (acc, [category, items]) => {
                        acc[category] = items.map((item) => ({
                            id: item._id,
                            ingredientId: item.ingredientId,
                            ingredientName: item.ingredientName,
                            quantity: item.quantity,
                            unit: item.unit,
                            recipeId: item.recipeId,
                            recipeName: item.recipeName,
                            isPurchased: item.isPurchased,
                        }));
                        return acc;
                    },
                    {}
                ),
                pagination: result.pagination,
                stats,
            },
        });
    } catch (error) {
        console.error("Error fetching grocery list:", error);
        res.status(500).json({
            success: false,
            message: error.message || "Failed to fetch grocery list",
            code: "FETCH_GROCERY_ERROR",
        });
    }
};

/**
 * Toggle purchase status of a grocery item
 * PATCH /api/groceries/:itemId/toggle
 */
exports.toggleGroceryItemStatus = async (req, res) => {
    try {
        const userId = req.user?.id;
        const { itemId } = req.params;

        if (!userId) {
            return res.status(401).json({
                success: false,
                message: "Authentication required",
                code: "UNAUTHORIZED",
            });
        }

        const item = await groceryService.toggleGroceryItemStatus(itemId, userId);

        res.status(200).json({
            success: true,
            data: {
                item: {
                    id: item._id,
                    ingredientName: item.ingredientName,
                    isPurchased: item.isPurchased,
                    purchasedAt: item.purchasedAt,
                },
            },
        });
    } catch (error) {
        console.error("Error toggling item status:", error);
        const statusCode = error.message.includes("Not authorized") ? 403 : 500;
        res.status(statusCode).json({
            success: false,
            message: error.message || "Failed to update item",
            code: "TOGGLE_ITEM_ERROR",
        });
    }
};

/**
 * Remove a grocery item
 * DELETE /api/groceries/:itemId
 */
exports.removeGroceryItem = async (req, res) => {
    try {
        const userId = req.user?.id;
        const { itemId } = req.params;

        if (!userId) {
            return res.status(401).json({
                success: false,
                message: "Authentication required",
                code: "UNAUTHORIZED",
            });
        }

        await groceryService.removeGroceryItem(itemId, userId);

        res.status(200).json({
            success: true,
            data: {
                message: "Item removed successfully",
            },
        });
    } catch (error) {
        console.error("Error removing item:", error);
        const statusCode = error.message.includes("Not authorized") ? 403 : 500;
        res.status(statusCode).json({
            success: false,
            message: error.message || "Failed to remove item",
            code: "REMOVE_ITEM_ERROR",
        });
    }
};

/**
 * Clear all purchased items
 * DELETE /api/groceries/clear/purchased
 */
exports.clearPurchasedItems = async (req, res) => {
    try {
        const userId = req.user?.id;

        if (!userId) {
            return res.status(401).json({
                success: false,
                message: "Authentication required",
                code: "UNAUTHORIZED",
            });
        }

        const result = await groceryService.clearPurchasedItems(userId);

        res.status(200).json({
            success: true,
            data: {
                message: "Purchased items cleared",
                deletedCount: result.deletedCount,
            },
        });
    } catch (error) {
        console.error("Error clearing purchased items:", error);
        res.status(500).json({
            success: false,
            message: error.message || "Failed to clear items",
            code: "CLEAR_ITEMS_ERROR",
        });
    }
};

/**
 * Get grocery statistics
 * GET /api/groceries/stats
 */
exports.getGroceryStats = async (req, res) => {
    try {
        const userId = req.user?.id;

        if (!userId) {
            return res.status(401).json({
                success: false,
                message: "Authentication required",
                code: "UNAUTHORIZED",
            });
        }

        const stats = await groceryService.getGroceryStats(userId);

        res.status(200).json({
            success: true,
            data: { stats },
        });
    } catch (error) {
        console.error("Error fetching grocery stats:", error);
        res.status(500).json({
            success: false,
            message: error.message || "Failed to fetch stats",
            code: "FETCH_STATS_ERROR",
        });
    }
};
