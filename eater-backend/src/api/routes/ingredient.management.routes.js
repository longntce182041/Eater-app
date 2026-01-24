// src/api/routes/ingredient.management.routes.js
const express = require("express");
const router = express.Router();
const ingredientController = require("../controllers/ingredient.management.controller");
const { protect, authorize } = require("../../middleware/authMiddleware");

// GET List & Search
router.get("/", ingredientController.getIngredients);

// Create
router.post("/create", ingredientController.createIngredient);

// Get Detail
router.get("/:id", ingredientController.getIngredientDetail);

// Update
router.put("/update/:id", ingredientController.updateIngredient);

// Delete
router.delete("/delete/:id", ingredientController.deleteIngredient);

module.exports = router;