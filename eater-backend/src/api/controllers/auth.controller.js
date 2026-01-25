const authService = require("../services/auth.service");

async function register(req, res, next) {
  try {
    const { email, password } = req.body;
    const result = await authService.register({ email, password });
    return res.status(201).json({
      status: "success",
      message: "Account created successfully. Please verify your email.",
      data: result,
    });
  } catch (err) {
    return next(err);
  }
}

async function login(req, res, next) {
  try {
    const { email, password } = req.body;
    const result = await authService.login({ email, password });
    return res.status(200).json({
      status: "success",
      message: "Login successful",
      data: result,
    });
  } catch (err) {
    return next(err);
  }
}

async function verifyEmail(req, res, next) {
  try {
    const { token } = req.body;
    const result = await authService.verifyEmail({ token });
    return res.status(200).json({
      status: "success",
      message: result.message,
    });
  } catch (err) {
    return next(err);
  }
}

async function requestPasswordReset(req, res, next) {
  try {
    const { email } = req.body;
    const result = await authService.requestPasswordReset({ email });
    return res.status(200).json({
      status: "success",
      message: result.message,
    });
  } catch (err) {
    return next(err);
  }
}

async function resetPassword(req, res, next) {
  try {
    const { otp, newPassword } = req.body;
    const result = await authService.resetPassword({ otp, newPassword });
    return res.status(200).json({
      status: "success",
      message: result.message,
    });
  } catch (err) {
    return next(err);
  }
}

async function refreshToken(req, res, next) {
  try {
    const { refreshToken } = req.body;
    const result = await authService.refreshToken({ refreshToken });
    return res.status(200).json({
      status: "success",
      data: result,
    });
  } catch (err) {
    return next(err);
  }
}

async function logout(req, res, next) {
  try {
    const { refreshToken } = req.body;
    await authService.logout({ refreshToken });
    return res.status(200).json({
      status: "success",
      message: "Logged out successfully",
    });
  } catch (err) {
    return next(err);
  }
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
