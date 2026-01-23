// Middleware for centralized error handling in the application

const errorHandler = (err, req, res, next) => {
  const status = err.status || 500;
  const message = err.message || "Internal Server Error";

  console.error(`[ERROR] ${status} - ${message}`);

  res.status(status).json({
    status: "error",
    statusCode: status,
    message,
  });
};

module.exports = { errorHandler };
