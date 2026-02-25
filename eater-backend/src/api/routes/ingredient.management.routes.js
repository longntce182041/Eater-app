// src/api/routes/ingredient.management.routes.js
const express = require("express");
const router = express.Router();
const ingredientController = require("../controllers/ingredient.management.controller");
const { protect, authorize } = require("../../middleware/authMiddleware");

// GET List & Search
router.get("/",protect, authorize('admin'), ingredientController.getIngredients);

// Create
router.post("/create",protect, authorize('admin'), ingredientController.createIngredient);

// Get Detail
router.get("/:id",protect, authorize('admin'), ingredientController.getIngredientDetail);

// Update
router.put("/update/:id",protect, authorize('admin'), ingredientController.updateIngredient);

// Delete
router.delete("/delete/:id",protect, authorize('admin'), ingredientController.deleteIngredient);

module.exports = router;