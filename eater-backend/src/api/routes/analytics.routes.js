const express = require("express");
const analyticsController = require("../controllers/analytics.controller");
const { protect, authorize } = require("../../middleware/authMiddleware");

const router = express.Router();

router.get("/overview", protect, authorize("admin"), analyticsController.getOverview);

module.exports = router;
