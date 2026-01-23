const express = require("express");

const authRoutes = require("./auth.admin.routes");
const userRoutes = require("./user.management.routes");
const ingredientRoutes = require("./ingredient.management.routes");


const router = express.Router();
router.use("/auth", authRoutes);
router.use("/users", userRoutes);
router.use("/ingredients", ingredientRoutes);


module.exports = router;
