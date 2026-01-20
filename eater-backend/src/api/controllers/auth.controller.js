const authService = require("../services/auth.service");

async function register(req, res, next) {
  try {
    const { email, password } = req.body;
    const result = await authService.register({ email, password });
    // result might be: { user, accessToken, refreshToken }
    return res.status(201).json(result);
  } catch (err) {
    return next(err);
  }
}

async function login(req, res, next) {
  try {
    const { email, password } = req.body;
    const result = await authService.login({ email, password });
    return res.status(200).json(result);
  } catch (err) {
    return next(err);
  }
}

async function refreshToken(req, res, next) {
  try {
    const { refreshToken } = req.body;
    const result = await authService.refreshToken({ refreshToken });
    return res.status(200).json(result);
  } catch (err) {
    return next(err);
  }
}

async function logout(req, res, next) {
  try {
    const { refreshToken } = req.body;
    await authService.logout({ refreshToken });
    return res.status(204).send();
  } catch (err) {
    return next(err);
  }
}

module.exports = {
  register,
  login,
  refreshToken,
  logout,
};
