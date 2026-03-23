const express = require("express");
const router = express.Router();
const reviewController = require("../controllers/review.management.controller");
const {protect, authorize} = require("../../middleware/authMiddleware");

// GET List & Search
router.get("/", protect, authorize('admin'), reviewController.getReviews);

// GET Detail
router.get("/:id", protect, authorize('admin'), reviewController.getReviewDetail);

// DELETE
router.delete("/delete/:id", protect, authorize('admin'), reviewController.deleteReview);

module.exports = router;