const express = require("express");
const profileController = require("../controllers/profile.controller");
const { validateRequest } = require("../../middleware/validateRequest");
const { protect } = require("../../middleware/authMiddleware");
const {
  createProfileSchema,
  updateProfileSchema,
} = require("../validators/profile.validators");

const router = express.Router();

// All profile routes require authentication
router.use(protect);

/**
 * @route   GET /api/profile/view
 * @desc    Get current user's profile
 * @access  Private
 * @returns {Object} User profile object
 */
router.get("/view", profileController.getProfile);

/**
 * @route   POST /api/profile/create
 * @desc    Create profile for current user (typically after registration)
 * @access  Private
 * @param   {Object} req.body - Profile data (age, gender, height, weight, etc.)
 * @returns {Object} Created profile object
 */
router.post(
  "/create",
  validateRequest(createProfileSchema),
  profileController.createProfile,
);

/**
 * @route   PUT /api/profile/update
 * @desc    Update current user's profile
 * @access  Private
 * @param   {Object} req.body - Profile fields to update
 * @returns {Object} Updated profile object
 */
router.put(
  "/update",
  validateRequest(updateProfileSchema),
  profileController.updateProfile,
);

module.exports = router;
