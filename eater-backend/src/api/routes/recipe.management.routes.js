const express = require("express");
const router = express.Router();
const recipeController = require("../controllers/recipe.management.controller");
const { protect, authorize } = require("../../middleware/authMiddleware");

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

module.exports = router;
