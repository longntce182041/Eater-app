// Middleware for centralized error handling in the application
const { AppError } = require("../utils/errors");

const errorHandler = (err, req, res, next) => {
  // Handle AppError instances
  if (err instanceof AppError) {
    return res.status(err.statusCode).json({
      status: err.status,
      statusCode: err.statusCode,
      message: err.message,
    });
  }

  // Handle JWT errors
  if (err.name === "JsonWebTokenError") {
    return res.status(401).json({
      status: "fail",
      statusCode: 401,
      message: "Invalid token",
    });
  }

  if (err.name === "TokenExpiredError") {
    return res.status(401).json({
      status: "fail",
      statusCode: 401,
      message: "Token expired",
    });
  }

  // Handle validation errors
  if (err.name === "ValidationError") {
    return res.status(400).json({
      status: "fail",
      statusCode: 400,
      message: err.message,
    });
  }

  // Handle MongoDB duplicate key error
  if (err.code === 11000) {
    const field = Object.keys(err.keyPattern)[0];
    return res.status(409).json({
      status: "fail",
      statusCode: 409,
      message: `${field} already exists`,
    });
  }

  // Default error handling
  const status = err.statusCode || err.status || 500;
  const message =
    err.message || "Internal Server Error";

  // Log error in development
  if (process.env.NODE_ENV === "development") {
    console.error(`[ERROR] ${status} - ${message}`);
    console.error(err.stack);
  } else {
    console.error(`[ERROR] ${status} - ${message}`);
  }

  res.status(status).json({
    status: status < 500 ? "fail" : "error",
    statusCode: status,
    message: process.env.NODE_ENV === "production" 
      ? "An error occurred" 
      : message,
  });
};

module.exports = { errorHandler };
