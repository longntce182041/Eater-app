const express = require("express");
const router = express.Router();
const viewRecipeDetailController = require("../controllers/viewrecipedetail.controller");
const { protect } = require("../../middleware/authMiddleware");

// GET full recipe details (with ingredients, steps, nutrition, micronutrients)
router.get("/:id/full-details", protect, viewRecipeDetailController.getFullRecipeDetails);

// GET basic recipe info
router.get("/:id", protect, viewRecipeDetailController.getRecipeBasicInfo);

module.exports = router;
