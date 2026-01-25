const express = require("express");
const healthController = require("../controllers/health.user.controller");

const router = express.Router();

// Public route to check server health
router.get("/", healthController.getHealthStatus);

// Protected routes for user health data
router.get("/dietary-references", healthController.getDietaryReferences);
router.get("/diet-types", healthController.getDietTypes);

module.exports = router;
