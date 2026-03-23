const express = require("express");
const router = express.Router();
const recipeController = require("../controllers/recipe.management.controller");
const {protect, authorize} = require("../../middleware/authMiddleware");



// GET List & Search
router.get("/",protect, recipeController.getRecipes);

// GET Nutrition Values
router.get("/:id/nutrition", protect, recipeController.getRecipeNutrition);

// GET Full Recipe Details (with ingredients, steps, micronutrients)
router.get("/:id/full-details", protect, recipeController.getFullRecipeDetail);

// GET Detail
router.get("/:id",protect, recipeController.getRecipeDetail);

// CREATE
router.post("/create",protect, recipeController.createRecipe);

// UPDATE
router.put("/update/:id",protect, authorize('admin'), recipeController.updateRecipe);

// DELETE
router.delete("/delete/:id",protect, authorize('admin'), recipeController.deleteRecipe);

module.exports = router;