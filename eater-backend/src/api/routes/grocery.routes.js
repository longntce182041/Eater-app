const express = require("express");
const router = express.Router();
const groceryController = require("../controllers/grocery.controller");
const { protect } = require("../../middleware/authMiddleware");

// === GROCERY ROUTES ===
// Add items to grocery list
router.post("/", protect, groceryController.addToGroceryList);

// Get user's grocery list
router.get("/", protect, groceryController.getGroceryList);

// Get grocery statistics
router.get("/stats", protect, groceryController.getGroceryStats);

// Toggle item purchase status
router.patch("/:itemId/toggle", protect, groceryController.toggleGroceryItemStatus);

// Remove an item from grocery list
router.delete("/:itemId", protect, groceryController.removeGroceryItem);

// Clear all purchased items
router.delete("/clear/purchased", protect, groceryController.clearPurchasedItems);

module.exports = router;
