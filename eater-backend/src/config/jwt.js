const jwtConfig = {
  secret: process.env.JWT_SECRET || "dev-secret",
  expiresIn: "1h",
  refreshSecret: process.env.JWT_REFRESH_SECRET || "dev-refresh-secret",
  refreshExpiresIn: "7d",
};

module.exports = { jwtConfig };
