const favoriteService = require("../services/favorite.recipe.service");

/**
 * Add recipe to favorites
 * @route POST /api/recipes/:recipeId/favorite
 */
async function addFavorite(req, res) {
    try {
        const userId = req.user?.id;
        const { recipeId } = req.params;

        if (!userId) {
            return res.status(401).json({
                success: false,
                message: "Authentication required",
            });
        }

        if (!recipeId) {
            return res.status(400).json({
                success: false,
                message: "Recipe ID is required",
            });
        }

        const result = await favoriteService.addFavoriteRecipe(userId, recipeId);

        return res.status(result.alreadyExists ? 200 : 201).json({
            success: true,
            message: result.message,
            data: {
                favoriteId: result.favorite._id,
                isFavorited: true,
            },
        });
    } catch (error) {
        console.error("Error adding favorite:", error);
        return res.status(500).json({
            success: false,
            message: error.message || "Failed to add favorite",
        });
    }
}

/**
 * Remove recipe from favorites
 * @route DELETE /api/recipes/:recipeId/favorite
 */
async function removeFavorite(req, res) {
    try {
        const userId = req.user?.id;
        const { recipeId } = req.params;

        if (!userId) {
            return res.status(401).json({
                success: false,
                message: "Authentication required",
            });
        }

        const result = await favoriteService.removeFavoriteRecipe(userId, recipeId);

        return res.status(200).json({
            success: true,
            message: result.message,
            data: {
                isFavorited: false,
            },
        });
    } catch (error) {
        console.error("Error removing favorite:", error);
        return res.status(500).json({
            success: false,
            message: "Failed to remove favorite",
        });
    }
}

/**
 * Toggle favorite status
 * @route POST /api/recipes/:recipeId/favorite/toggle
 */
async function toggleFavorite(req, res) {
    try {
        const userId = req.user?.id;
        const { recipeId } = req.params;

        if (!userId) {
            return res.status(401).json({
                success: false,
                message: "Authentication required",
            });
        }

        // Check current status
        const isFavorited = await favoriteService.isRecipeFavorited(
            userId,
            recipeId,
        );

        let result;
        if (isFavorited) {
            result = await favoriteService.removeFavoriteRecipe(userId, recipeId);
            return res.json({
                success: true,
                message: "Removed from favorites",
                data: {
                    isFavorited: false,
                    action: "removed",
                },
            });
        } else {
            result = await favoriteService.addFavoriteRecipe(userId, recipeId);
            return res.status(201).json({
                success: true,
                message: "Added to favorites",
                data: {
                    isFavorited: true,
                    favoriteId: result.favorite._id,
                    action: "added",
                },
            });
        }
    } catch (error) {
        console.error("Error toggling favorite:", error);
        return res.status(500).json({
            success: false,
            message: "Failed to toggle favorite",
        });
    }
}

/**
 * Get user's favorite recipes
 * @route GET /api/recipes/favorites
 */
async function getUserFavorites(req, res) {
    try {
        const userId = req.user?.id;

        if (!userId) {
            return res.status(401).json({
                success: false,
                message: "Authentication required",
            });
        }

        const { page = 1, limit = 20, sortBy, sortOrder } = req.query;

        const result = await favoriteService.getUserFavoriteRecipes(userId, {
            page: parseInt(page),
            limit: parseInt(limit),
            sortBy,
            sortOrder,
        });

        return res.json({
            success: true,
            data: {
                recipes: result.favorites.map((fav) => ({
                    favoriteId: fav._id,
                    favoritedAt: fav.createdAt,
                    recipe: fav.recipeId,
                })),
                pagination: result.pagination,
            },
        });
    } catch (error) {
        console.error("Error getting favorites:", error);
        return res.status(500).json({
            success: false,
            message: "Failed to get favorites",
        });
    }
}

/**
 * Check if recipe is favorited
 * @route GET /api/recipes/:recipeId/favorite/status
 */
async function getFavoriteStatus(req, res) {
    try {
        const userId = req.user?.id;
        const { recipeId } = req.params;

        if (!userId) {
            return res.json({
                success: true,
                data: { isFavorited: false },
            });
        }

        const isFavorited = await favoriteService.isRecipeFavorited(
            userId,
            recipeId,
        );

        return res.json({
            success: true,
            data: { isFavorited },
        });
    } catch (error) {
        console.error("Error checking favorite status:", error);
        return res.status(500).json({
            success: false,
            message: "Failed to check favorite status",
        });
    }
}

/**
 * Get favorite count for user
 * @route GET /api/recipes/favorites/count
 */
async function getFavoriteCount(req, res) {
    try {
        const userId = req.user?.id;

        if (!userId) {
            return res.json({
                success: true,
                data: { count: 0 },
            });
        }

        const count = await favoriteService.getFavoriteCount(userId);

        return res.json({
            success: true,
            data: { count },
        });
    } catch (error) {
        console.error("Error getting favorite count:", error);
        return res.status(500).json({
            success: false,
            message: "Failed to get favorite count",
        });
    }
}

module.exports = {
    addFavorite,
    removeFavorite,
    toggleFavorite,
    getUserFavorites,
    getFavoriteStatus,
    getFavoriteCount,
};
