const jwt = require("jsonwebtoken");
const { jwtConfig } = require("../config/jwt");

function authMiddleware(req, res, next) {
  const authHeader = req.headers.authorization || "";
  const token = authHeader.startsWith("Bearer ") ? authHeader.slice(7) : null;

  if (!token) {
    return res.status(401).json({ message: "Authentication token missing" });
  }

  try {
    const payload = jwt.verify(token, jwtConfig.secret);
    req.user = payload; // { id, role, ... }
    return next();
  } catch (err) {
    return res.status(401).json({ message: "Invalid or expired token" });
  }
}

module.exports = { authMiddleware };
