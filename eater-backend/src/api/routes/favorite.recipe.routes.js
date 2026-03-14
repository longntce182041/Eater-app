const express = require("express");
const router = express.Router();
const favoriteController = require("../controllers/favorite.recipe.controller");
const { protect } = require("../../middleware/authMiddleware");

// All routes require authentication
router.use(protect);

// Get user's favorite recipes
router.get("/favorites", favoriteController.getUserFavorites);

// Get favorite count
router.get("/favorites/count", favoriteController.getFavoriteCount);

// Add recipe to favorites
router.post("/:recipeId/favorite", favoriteController.addFavorite);

// Remove recipe from favorites
router.delete("/:recipeId/favorite", favoriteController.removeFavorite);

// Toggle favorite status (convenience endpoint)
router.post("/:recipeId/favorite/toggle", favoriteController.toggleFavorite);

// Check favorite status
router.get("/:recipeId/favorite/status", favoriteController.getFavoriteStatus);

module.exports = router;
