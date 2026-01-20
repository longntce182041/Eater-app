const express = require("express");
const authController = require("../controllers/auth.controller");
const { validateRequest } = require("../../middleware/validateRequest");
const {
  loginSchema,
  registerSchema,
} = require("../validators/auth.validators");

const router = express.Router();

// POST /api/v1/auth/register
router.post(
  "/register",
  validateRequest(registerSchema),
  authController.register,
);

// POST /api/v1/auth/login
router.post("/login", validateRequest(loginSchema), authController.login);

// POST /api/v1/auth/refresh
router.post("/refresh", authController.refreshToken);

// POST /api/v1/auth/logout
router.post("/logout", authController.logout);

module.exports = router;
