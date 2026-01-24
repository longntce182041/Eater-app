// Middleware for handling 404 Not Found errors in the application
const { authorize } = require("./authMiddleware");

function requireRole(...roles) {
    return authorize(...roles);
}

module.exports = { requireRole, authorize };