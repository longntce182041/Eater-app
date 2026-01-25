const express = require("express");
const router = express.Router();
const micronutrientController = require("../controllers/micronutrient.management.controller");
const { protect, authorize } = require("../../middleware/authMiddleware");

// GET List & Search Micronutrients (Public)
router.get("/", micronutrientController.getMicronutrients);

// GET Micronutrient Detail (Public)
router.get("/:id", micronutrientController.getMicronutrientDetail);

// POST Create Micronutrient (Protected - Admin/Nutritionist only)
router.post("/create", protect, authorize("admin", "nutritionist"), micronutrientController.createMicronutrient);

// PUT Update Micronutrient (Protected - Admin/Nutritionist only)
router.put("/update/:id", protect, authorize("admin", "nutritionist"), micronutrientController.updateMicronutrient);

// DELETE Micronutrient (Protected - Admin only)
router.delete("/delete/:id", protect, authorize("admin"), micronutrientController.deleteMicronutrient);

module.exports = router;
