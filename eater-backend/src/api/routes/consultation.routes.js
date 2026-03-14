const express = require("express");
const { protect, authorize } = require("../../middleware/authMiddleware");
const consultationController = require("../controllers/consultation.controller");

const router = express.Router();

// User routes
router.post("/", protect, consultationController.createConsultation);
router.get("/my", protect, consultationController.getMyConsultations);
router.get("/nutritionists", protect, consultationController.getNutritionists);

// Nutritionist / Admin routes
router.get(
  "/requests",
  protect,
  authorize("nutritionist", "admin"),
  consultationController.getNutritionistRequests
);
router.post(
  "/:id/reply",
  protect,
  authorize("nutritionist", "admin"),
  consultationController.replyToConsultation
);
router.patch(
  "/:id/status",
  protect,
  authorize("nutritionist", "admin", "user"),
  consultationController.updateConsultationStatus
);

// Detail — any authenticated user (access control inside service)
router.get("/:id", protect, consultationController.getConsultationDetail);

module.exports = router;
