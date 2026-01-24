const express = require("express");
const profileController = require("../controllers/profile.controller");
const { validateRequest } = require("../../middleware/validateRequest");
const { authMiddleware } = require("../../middleware/authMiddleware");
const {
    createProfileSchema,
    updateProfileSchema,
} = require("../validators/profile.validators");

const router = express.Router();

// All profile routes require authentication
router.use(authMiddleware);

/**
 * @route   GET /api/profile
 * @desc    Get current user's profile
 * @access  Private
 * @returns {Object} User profile object
 */
router.get("/", profileController.getProfile);

/**
 * @route   POST /api/profile
 * @desc    Create profile for current user (typically after registration)
 * @access  Private
 * @param   {Object} req.body - Profile data (age, gender, height, weight, etc.)
 * @returns {Object} Created profile object
 */
router.post(
    "/",
    validateRequest(createProfileSchema),
    profileController.createProfile,
);

/**
 * @route   PUT /api/profile
 * @desc    Update current user's profile
 * @access  Private
 * @param   {Object} req.body - Profile fields to update
 * @returns {Object} Updated profile object
 */
router.put(
    "/",
    validateRequest(updateProfileSchema),
    profileController.updateProfile,
);

module.exports = router;
