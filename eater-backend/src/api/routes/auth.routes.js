const express = require("express");
const authController = require("../controllers/auth.controller");
const { validateRequest } = require("../../middleware/validateRequest");
const {
  loginSchema,
  registerSchema,
  verifyEmailSchema,
  requestPasswordResetSchema,
  resetPasswordSchema,
} = require("../validators/auth.validators");

const router = express.Router();

/**
 * @route   POST /api/auth/user/register
 * @desc    Register a new user account
 * @access  Public
 */
router.post(
  "/register",
  validateRequest(registerSchema),
  authController.register,
);

/**
 * @route   POST /api/auth/user/login
 * @desc    Login user and return JWT tokens
 * @access  Public
 */
router.post("/login", validateRequest(loginSchema), authController.login);

/**
 * @route   POST /api/auth/user/verify-email
 * @desc    Verify user email with verification token
 * @access  Public
 */
router.post(
  "/verify-email",
  validateRequest(verifyEmailSchema),
  authController.verifyEmail,
);

/**
 * @route   POST /api/auth/user/request-password-reset
 * @desc    Request password reset - sends reset token to email
 * @access  Public
 */
router.post(
  "/request-password-reset",
  validateRequest(requestPasswordResetSchema),
  authController.requestPasswordReset,
);

/**
 * @route   POST /api/auth/user/reset-password
 * @desc    Reset password with reset token
 * @access  Public
 */
router.post(
  "/reset-password",
  validateRequest(resetPasswordSchema),
  authController.resetPassword,
);

/**
 * @route   POST /api/auth/user/refresh
 * @desc    Refresh access token using refresh token
 * @access  Public
 */
router.post("/refresh", authController.refreshToken);

/**
 * @route   POST /api/auth/user/logout
 * @desc    Logout user (invalidate refresh token)
 * @access  Public
 */
router.post("/logout", authController.logout);

module.exports = router;
