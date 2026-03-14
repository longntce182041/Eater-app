const express = require("express");
const router = express.Router();
const reminderController = require("../controllers/reminder.controller");
const { protect } = require("../../middleware/authMiddleware");

// All reminder routes require authentication
router.get("/", protect, reminderController.getAll);
router.put("/:mealType", protect, reminderController.upsert);
router.patch("/:mealType/toggle", protect, reminderController.toggle);
router.delete("/:mealType", protect, reminderController.remove);

module.exports = router;
