const jwt = require("jsonwebtoken");
const bcrypt = require("bcrypt");
const crypto = require("crypto");
const { jwtConfig } = require("../../config/jwt");
const userRepository = require("../repositories/user.repository");
const { AppError } = require("../../utils/errors");

// Hash password with bcrypt
async function hashPassword(password) {
  const saltRounds = 10;
  return bcrypt.hash(password, saltRounds);
}

// Compare password with hash
async function comparePassword(password, hash) {
  return bcrypt.compare(password, hash);
}

// Generate email verification token
function generateEmailVerificationToken() {
  return crypto.randomBytes(32).toString("hex");
}

// Generate password reset token
function generatePasswordResetToken() {
  return crypto.randomBytes(32).toString("hex");
}

// Generate JWT tokens
function generateTokens(user) {
  const payload = { sub: user._id.toString(), role: user.role };
  const accessToken = jwt.sign(payload, jwtConfig.secret, {
    expiresIn: jwtConfig.expiresIn,
  });
  const refreshToken = jwt.sign(payload, jwtConfig.refreshSecret, {
    expiresIn: jwtConfig.refreshExpiresIn,
  });

  return { accessToken, refreshToken };
}

// Register new user
async function register({ email, password }) {
  // Check if user already exists
  const existingUser = await userRepository.findByEmail(email);
  if (existingUser) {
    throw new AppError("Email already registered", 409);
  }

  // Hash password
  const passwordHash = await hashPassword(password);

  // Generate email verification token
  const emailVerificationToken = generateEmailVerificationToken();
  const emailVerificationTokenExpires = new Date();
  emailVerificationTokenExpires.setHours(
    emailVerificationTokenExpires.getHours() + 24,
  ); // Token expires in 24 hours

  // Create user
  const user = await userRepository.createUser({
    email: email.toLowerCase().trim(),
    passwordHash,
    emailVerificationToken,
    emailVerificationTokenExpires,
    isActive: true,
  });

  // Remove sensitive data before returning
  const userResponse = {
    id: user._id,
    email: user.email,
    role: user.role,
    isActive: user.isActive,
    createdAt: user.createdAt,
  };

  // Generate tokens (auto-login right after register)
  const tokens = generateTokens(user);

  // In production, you would send verification email here
  // For now, we'll return the token in the response (in production, remove this)
  return {
    user: userResponse,
    ...tokens,
    emailVerificationToken, // Remove this in production - only for development
  };
}

// Login user
async function login({ email, password }) {
  // Find user by email
  const user = await userRepository.findByEmail(email);
  if (!user) {
    throw new AppError("Invalid email or password", 401);
  }

  // Check if user is active
  if (!user.isActive) {
    throw new AppError("Account is deactivated", 403);
  }

  // Verify password
  const isPasswordValid = await comparePassword(password, user.passwordHash);
  if (!isPasswordValid) {
    throw new AppError("Invalid email or password", 401);
  }

  // Remove sensitive data before returning
  const userResponse = {
    id: user._id,
    email: user.email,
    role: user.role,
    createdAt: user.createdAt,
  };

  // Generate tokens
  const tokens = generateTokens(user);

  return {
    user: userResponse,
    ...tokens,
  };
}

// Verify email
async function verifyEmail({ token }) {
  // Find user by verification token
  const user = await userRepository.findByEmailVerificationToken(token);
  if (!user) {
    throw new AppError("Invalid or expired verification token", 400);
  }

  // Check if already verified
  if (user.isEmailVerified) {
    throw new AppError("Email already verified", 400);
  }

  // Update user to mark email as verified
  await userRepository.updateUser(user._id, {
    isEmailVerified: true,
    emailVerificationToken: null,
    emailVerificationTokenExpires: null,
  });

  return {
    message: "Email verified successfully",
  };
}

// Request password reset
async function requestPasswordReset({ email }) {
  // Find user by email
  const user = await userRepository.findByEmail(email);
  if (!user) {
    // Don't reveal if email exists or not for security
    return {
      message:
        "If the email exists, a password reset link has been sent",
    };
  }

  // Generate password reset token
  const passwordResetToken = generatePasswordResetToken();
  const passwordResetTokenExpires = new Date();
  passwordResetTokenExpires.setHours(
    passwordResetTokenExpires.getHours() + 1,
  ); // Token expires in 1 hour

  // Update user with reset token
  await userRepository.updateUser(user._id, {
    passwordResetToken,
    passwordResetTokenExpires,
  });

  // In production, you would send password reset email here
  // For now, we'll return the token in the response (in production, remove this)
  return {
    message:
      "If the email exists, a password reset link has been sent",
    passwordResetToken, // Remove this in production - only for development
  };
}

// Reset password
async function resetPassword({ token, newPassword }) {
  // Find user by reset token
  const user = await userRepository.findByPasswordResetToken(token);
  if (!user) {
    throw new AppError("Invalid or expired reset token", 400);
  }

  // Hash new password
  const passwordHash = await hashPassword(newPassword);

  // Update user password and clear reset token
  await userRepository.updateUser(user._id, {
    passwordHash,
    passwordResetToken: null,
    passwordResetTokenExpires: null,
    isEmailVerified: true,
  });

  return {
    message: "Password reset successfully",
  };
}

// Refresh token
async function refreshToken({ refreshToken }) {
  try {
    // Verify refresh token
    const payload = jwt.verify(refreshToken, jwtConfig.refreshSecret);

    // Find user
    const user = await userRepository.findById(payload.sub);
    if (!user) {
      throw new AppError("User not found", 404);
    }

    // Check if user is active
    if (!user.isActive) {
      throw new AppError("Account is deactivated", 403);
    }

    // Generate new tokens
    const tokens = generateTokens(user);

    return tokens;
  } catch (error) {
    if (error.name === "JsonWebTokenError" || error.name === "TokenExpiredError") {
      throw new AppError("Invalid or expired refresh token", 401);
    }
    throw error;
  }
}

// Logout
async function logout({ refreshToken }) {
  // In a production system, you might want to:
  // 1. Store refresh tokens in a database/Redis and invalidate them
  // 2. Maintain a blacklist of tokens
  // For now, we'll just return success
  // The client should delete the token from storage
  return {
    message: "Logged out successfully",
  };
}

module.exports = {
  register,
  login,
  verifyEmail,
  requestPasswordReset,
  resetPassword,
  refreshToken,
  logout,
};
