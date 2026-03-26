const express = require("express");
const healthController = require("../controllers/health.user.controller");
const { protect } = require("../../middleware/authMiddleware");

const router = express.Router();

// Public route to check server health
router.get("/", healthController.getHealthStatus);

// Public route to get diet types
router.get("/diet-types", healthController.getDietTypes);

// Protected route - save user profile to database
router.post("/user-profile", protect, healthController.setUserProfile);

router.post("/dietary-references", healthController.setDietaryReference);
module.exports = router;
