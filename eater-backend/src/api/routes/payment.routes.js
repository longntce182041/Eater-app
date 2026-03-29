const express = require("express");
const paymentController = require("../controllers/payment.controller");
const { protect } = require("../../middleware/authMiddleware");

const router = express.Router();

// Create PayOS payment link for upgrading current user to Pro
router.post("/pro/checkout", protect, paymentController.createProCheckout);

// PayOS webhook callback: update Pro status after successful payment
router.post(
  "/webhook/payos",
  express.raw({ type: "application/json" }),
  paymentController.handlePayOSWebhook,
);

// Get current user's Pro status
router.get("/pro/status", protect, paymentController.getProStatus);

// Get configured PayOS return/cancel URLs
router.get("/payos/urls", protect, paymentController.getPayOSUrls);

module.exports = router;
