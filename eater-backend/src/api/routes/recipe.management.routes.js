const express = require("express");
const router = express.Router();
const recipeController = require("../controllers/recipe.management.controller");
const favoriteController = require("../controllers/favorite.recipe.controller");
const reviewController = require("../controllers/recipe.review.controller");
const cookingController = require("../controllers/cooking.controller");
const { protect, authorize } = require("../../middleware/authMiddleware");

// === FAVORITE ROUTES ===
router.get("/favorites", protect, favoriteController.getUserFavorites);
router.get("/favorites/count", protect, favoriteController.getFavoriteCount);

// === REVIEW (USER) ===
router.get("/reviews/user/list", protect, reviewController.getUserReviews);

// === RECIPE ROUTES ===

// GET Filter options derived from database
router.get("/filter-options", protect, recipeController.getRecipeFilterOptions);
// GET List & Search
router.get("/", protect, recipeController.getRecipes);

// GET Nutrition
router.get("/:id/nutrition", protect, recipeController.getRecipeNutrition);

// GET Full details
router.get("/:id/full-details", protect, recipeController.getFullRecipeDetail);

// === REVIEW ROUTES (đặt trước /:id) ===
router.get("/:recipeId/reviews", protect, reviewController.getRecipeReviews);
router.get("/:recipeId/reviews/user/mine", protect, reviewController.getUserRecipeReview);
router.post("/:recipeId/reviews", protect, reviewController.addReview);
router.delete("/:recipeId/reviews/:reviewId", protect, reviewController.deleteReview);

// === FAVORITE ACTIONS ===
router.get("/:recipeId/favorite/status", protect, favoriteController.getFavoriteStatus);
router.post("/:recipeId/favorite/toggle", protect, favoriteController.toggleFavorite);
router.post("/:recipeId/favorite", protect, favoriteController.addFavorite);
router.delete("/:recipeId/favorite", protect, favoriteController.removeFavorite);

// GET Detail (để CUỐI)
router.get("/:id", protect, recipeController.getRecipeDetail);

// CREATE
router.post("/create", protect, recipeController.createRecipe);

// UPDATE
router.put("/update/:id", protect, authorize("admin"), recipeController.updateRecipe);

// DELETE
router.delete("/delete/:id", protect, authorize("admin"), recipeController.deleteRecipe);

module.exports = router;
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
