// Middleware for handling 404 Not Found errors in the application

const notFoundHandler = (req, res) => {
  res.status(404).json({
    status: "fail",
    message: `Route ${req.originalUrl} not found`,
  });
};

module.exports = { notFoundHandler };
