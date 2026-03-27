const express = require("express");
const homeController = require("../controllers/home.dashboard.controller");
const { protect } = require("../../middleware/authMiddleware");

const router = express.Router();

// Protected routes - require authentication
router.get("/dashboard", protect, homeController.getHomeDashboard);
router.get("/upcoming-meals", protect, homeController.getUpcomingMeals);

module.exports = router;
