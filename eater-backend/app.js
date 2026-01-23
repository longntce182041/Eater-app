const express = require("express");
const cors = require("cors");
const helmet = require("helmet");

const { errorHandler } = require("./src/middleware/errorHandler");
const { notFoundHandler } = require("./src/middleware/notFoundHandler");
const Routes = require("./src/api/routes");

const app = express();

app.use(helmet());
app.use(cors({
    origin: "http://localhost:5173", // Chỉ cho phép Frontend của bạn gọi vào
    credentials: true
}));
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
