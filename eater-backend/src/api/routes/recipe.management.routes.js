const express = require("express");
const router = express.Router();
const recipeController = require("../controllers/recipe.management.controller");
const favoriteController = require("../controllers/favorite.recipe.controller");
const reviewController = require("../controllers/recipe.review.controller");
const cookingController = require("../controllers/cooking.controller");
const { protect, authorize } = require("../../middleware/authMiddleware");

// === FAVORITE ROUTES ===
// Get user's favorite recipes
router.get("/favorites", protect, favoriteController.getUserFavorites);
// Get favorite count
router.get("/favorites/count", protect, favoriteController.getFavoriteCount);

// === RECIPE ROUTES ===
// GET Filter options derived from database
router.get("/filter-options", protect, recipeController.getRecipeFilterOptions);
// GET List & Search
router.get("/", protect, recipeController.getRecipes);
// GET Detail
router.get("/:id", protect, recipeController.getRecipeDetail);
// CREATE
router.post("/create", protect, recipeController.createRecipe);
// UPDATE
router.put(
  "/update/:id",
  protect,
  authorize("admin"),
  recipeController.updateRecipe,
);
// DELETE
router.delete(
  "/delete/:id",
  protect,
  authorize("admin"),
  recipeController.deleteRecipe,
);

// GET Nutrition Values
router.get("/:id/nutrition", recipeController.getRecipeNutrition);

// === FAVORITE ACTIONS (must be after /:id routes to avoid conflicts) ===
// Check favorite status
router.get("/:recipeId/favorite/status", protect, favoriteController.getFavoriteStatus);
// Toggle favorite (add/remove)
router.post("/:recipeId/favorite/toggle", protect, favoriteController.toggleFavorite);
// Add to favorites
router.post("/:recipeId/favorite", protect, favoriteController.addFavorite);
// Remove from favorites
router.delete("/:recipeId/favorite", protect, favoriteController.removeFavorite);

// === REVIEW ROUTES ===
// Get user's reviews
router.get("/reviews/user/list", protect, reviewController.getUserReviews);
// Get reviews for a recipe
router.get("/:recipeId/reviews", protect, reviewController.getRecipeReviews);
// Get user's review for a specific recipe
router.get("/:recipeId/reviews/user/mine", protect, reviewController.getUserRecipeReview);
// Add/update review
router.post("/:recipeId/reviews", protect, reviewController.addReview);
// Delete review
router.delete("/:recipeId/reviews/:reviewId", protect, reviewController.deleteReview);

// === COOKING SESSION ROUTES ===
// Start a new cooking session
router.get("/:recipeId/cook/start", protect, cookingController.startCookingSession);
// Get current cooking session
router.get("/:recipeId/cook/session/:sessionId", protect, cookingController.getCookingSession);
// Mark a step as completed
router.patch("/:recipeId/cook/session/:sessionId/step/:stepNumber", protect, cookingController.completeStep);
// Pause cooking session
router.post("/:recipeId/cook/session/:sessionId/pause", protect, cookingController.pauseCookingSession);
// Resume cooking session
router.post("/:recipeId/cook/session/:sessionId/resume", protect, cookingController.resumeCookingSession);
// Complete cooking session
router.post("/:recipeId/cook/session/:sessionId/complete", protect, cookingController.completeCookingSession);
// Get recipe steps with details
router.get("/:recipeId/steps", protect, cookingController.getRecipeSteps);

module.exports = router;
