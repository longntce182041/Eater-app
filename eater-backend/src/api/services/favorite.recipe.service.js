const { FavoriteRecipe } = require("../../models/favorite_recipes");
const { Recipe } = require("../../models/Recipe");

/**
 * Add recipe to user's favorites
 * @param {string} userId - User ID
 * @param {string} recipeId - Recipe ID
 * @returns {Promise<Object>} Favorite record
 */
async function addFavoriteRecipe(userId, recipeId) {
    try {
        // Check if recipe exists
        const recipe = await Recipe.findById(recipeId);
        if (!recipe) {
            throw new Error("Recipe not found");
        }

        // Check if already favorited
        const existing = await FavoriteRecipe.findOne({ userId, recipeId });
        if (existing) {
            return {
                alreadyExists: true,
                favorite: existing,
                message: "Recipe already in favorites",
            };
        }

        // Create favorite
        const favorite = new FavoriteRecipe({
            userId,
            recipeId,
        });

        await favorite.save();

        return {
            alreadyExists: false,
            favorite,
            message: "Recipe added to favorites",
        };
    } catch (error) {
        console.error("Error adding favorite recipe:", error);
        throw error;
    }
}

/**
 * Remove recipe from user's favorites
 * @param {string} userId - User ID
 * @param {string} recipeId - Recipe ID
 * @returns {Promise<Object>} Deletion result
 */
async function removeFavoriteRecipe(userId, recipeId) {
    try {
        const result = await FavoriteRecipe.findOneAndDelete({ userId, recipeId });

        if (!result) {
            return {
                found: false,
                message: "Recipe not in favorites",
            };
        }

        return {
            found: true,
            message: "Recipe removed from favorites",
        };
    } catch (error) {
        console.error("Error removing favorite recipe:", error);
        throw error;
    }
}

/**
 * Get user's favorite recipes
 * @param {string} userId - User ID
 * @param {Object} options - Pagination options
 * @returns {Promise<Object>} Favorite recipes with pagination
 */
async function getUserFavoriteRecipes(userId, options = {}) {
    try {
        const {
            page = 1,
            limit = 20,
            sortBy = "createdAt",
            sortOrder = "desc",
        } = options;

        const skip = (page - 1) * limit;
        const sort = { [sortBy]: sortOrder === "desc" ? -1 : 1 };

        // Get favorites with populated recipe details
        const favorites = await FavoriteRecipe.find({ userId })
            .sort(sort)
            .skip(skip)
            .limit(limit)
            .populate({
                path: "recipeId",
                select: "_id name description imageUrl cookingTime baseServings status rating nutritionInfo",
            })
            .lean();

        // Count total favorites
        const total = await FavoriteRecipe.countDocuments({ userId });

        // Filter out any favorites where recipe was deleted
        const validFavorites = favorites.filter((fav) => fav.recipeId != null);

        return {
            favorites: validFavorites,
            pagination: {
                total,
                page,
                limit,
                totalPages: Math.ceil(total / limit),
                hasMore: page * limit < total,
            },
        };
    } catch (error) {
        console.error("Error getting user favorite recipes:", error);
        throw error;
    }
}

/**
 * Check if recipe is favorited by user
 * @param {string} userId - User ID
 * @param {string} recipeId - Recipe ID
 * @returns {Promise<boolean>} True if favorited
 */
async function isRecipeFavorited(userId, recipeId) {
    try {
        const favorite = await FavoriteRecipe.findOne({ userId, recipeId });
        return favorite != null;
    } catch (error) {
        console.error("Error checking favorite status:", error);
        return false;
    }
}

/**
 * Get favorite status for multiple recipes
 * @param {string} userId - User ID
 * @param {Array<string>} recipeIds - Array of recipe IDs
 * @returns {Promise<Object>} Map of recipeId -> isFavorited
 */
async function getBatchFavoriteStatus(userId, recipeIds) {
    try {
        const favorites = await FavoriteRecipe.find({
            userId,
            recipeId: { $in: recipeIds },
        }).select("recipeId");

        const favoriteMap = {};
        recipeIds.forEach((id) => {
            favoriteMap[id] = false;
        });

        favorites.forEach((fav) => {
            favoriteMap[fav.recipeId.toString()] = true;
        });

        return favoriteMap;
    } catch (error) {
        console.error("Error getting batch favorite status:", error);
        return {};
    }
}

/**
 * Get count of user's favorite recipes
 * @param {string} userId - User ID
 * @returns {Promise<number>} Count of favorites
 */
async function getFavoriteCount(userId) {
    try {
        const count = await FavoriteRecipe.countDocuments({ userId });
        return count;
    } catch (error) {
        console.error("Error getting favorite count:", error);
        return 0;
    }
}

module.exports = {
    addFavoriteRecipe,
    removeFavoriteRecipe,
    getUserFavoriteRecipes,
    isRecipeFavorited,
    getBatchFavoriteStatus,
    getFavoriteCount,
};
