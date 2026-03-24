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
const allowedOriginsRaw = process.env.ALLOWED_ORIGINS || "*";
const isWildcardOrigin = allowedOriginsRaw.trim() === "*";
const allowedOrigins = isWildcardOrigin
  ? true
  : allowedOriginsRaw.split(",").map((origin) => origin.trim());

app.use(
  cors({
    origin: allowedOrigins,
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
