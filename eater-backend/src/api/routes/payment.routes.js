const express = require("express");
const paymentController = require("../controllers/payment.controller");
const { protect } = require("../../middleware/authMiddleware");
const { loadProStatus } = require("../../middleware/proMiddleware");

const router = express.Router();

// Create PayOS payment link for upgrading current user to Pro
router.post("/pro/checkout", protect, paymentController.createProCheckout);

// PayOS webhook callback: update Pro status after successful payment
router.post("/payos/webhook", paymentController.handlePayOSWebhook);

// Get current user's Pro status
router.get(
  "/pro/status",
  protect,
  loadProStatus,
  paymentController.getProStatus,
);

// Get available Pro plans (monthly/yearly)
router.get("/pro/plans", protect, paymentController.getProPlans);

// Get configured PayOS return/cancel URLs
router.get("/payos/urls", protect, paymentController.getPayOSUrls);

module.exports = router;
