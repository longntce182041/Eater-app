require("dotenv").config();
const express = require("express");
const cors = require("cors");
const helmet = require("helmet");

const { errorHandler } = require("./src/middleware/errorHandler");
const { notFoundHandler } = require("./src/middleware/notFoundHandler");
const Routes = require("./src/api/routes");

const app = express();

app.use(helmet());
// CORS configuration for mobile apps and web clients
app.use(
  cors({
    origin: process.env.ALLOWED_ORIGINS
      ? process.env.ALLOWED_ORIGINS.split(",")
      : "*", // Allow all origins in development
    credentials: true,
    methods: ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"],
    allowedHeaders: ["Content-Type", "Authorization"],
  }),
);
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
//connect to database
require("./src/config/mongo");
// API versioned routes
app.use("/api", Routes);
// 404 handler
app.use(notFoundHandler);

// Central error handler
app.use(errorHandler);

module.exports = app;
