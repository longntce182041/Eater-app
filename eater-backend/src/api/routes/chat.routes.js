const express = require("express");
const { protect, authorize } = require("../../middleware/authMiddleware");
const {
  getChatHistory,
  getContacts,
  getNutritionistChatHistory,
  getNutritionists,
} = require("../controllers/chat.controller");

const router = express.Router();

// GET /api/chat/nutritionists — user: list of nutritionists to chat with
router.get("/nutritionists", protect, getNutritionists);

// GET /api/chat/contacts — nutritionist: list of users they can chat with
router.get(
  "/contacts",
  protect,
  authorize("nutritionist", "admin"),
  getContacts
);

// GET /api/chat/user/:userId/messages — nutritionist: history with a user
router.get(
  "/user/:userId/messages",
  protect,
  authorize("nutritionist", "admin"),
  getNutritionistChatHistory
);

// GET /api/chat/:nutritionistId/messages — user: history with a nutritionist
router.get("/:nutritionistId/messages", protect, getChatHistory);

module.exports = router;
