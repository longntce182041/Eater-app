const jwt = require("jsonwebtoken");
const { jwtConfig } = require("../../../src/config/jwt");
const userRepository = require("../repositories/user.repository");

async function register({ email, password }) {
  // TODO: hash password, save user via repository
  const user = await userRepository.createUser({ email, passwordHash: "TODO" });
  const tokens = generateTokens(user);
  return { user, ...tokens };
}

async function login({ email, password }) {
  // TODO: validate user credentials via repository
  const user = await userRepository.findByEmail(email);
  // TODO: verify password
  const tokens = generateTokens(user);
  return { user, ...tokens };
}

async function refreshToken({ refreshToken }) {
  // TODO: verify & rotate refresh token
  const payload = jwt.verify(refreshToken, jwtConfig.refreshSecret);
  const user = await userRepository.findById(payload.sub);
  const tokens = generateTokens(user);
  return { user, ...tokens };
}

async function logout({ refreshToken }) {
  // TODO: invalidate refresh token if using token store/blacklist
  return;
}

function generateTokens(user) {
  const payload = { sub: user.id, role: user.role };
  const accessToken = jwt.sign(payload, jwtConfig.secret, {
    expiresIn: jwtConfig.expiresIn,
  });
  const refreshToken = jwt.sign(payload, jwtConfig.refreshSecret, {
    expiresIn: jwtConfig.refreshExpiresIn,
  });

  return { accessToken, refreshToken };
}

module.exports = {
  register,
  login,
  refreshToken,
  logout,
};
