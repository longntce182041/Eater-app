const express = require("express");

const authRoutes = require("./auth.admin.routes");
const userRoutes = require("./user.management.routes");
const ingredientRoutes = require("./ingredient.management.routes");
const micronutrientRoutes = require("./micronutrient.management.routes");
const adminBackupRoutes = require("./admin.backup.routes");


const router = express.Router();
router.use("/auth", authRoutes);
router.use("/users", userRoutes);
router.use("/ingredients", ingredientRoutes);
router.use("/micronutrients", micronutrientRoutes);
router.use('/admin', adminBackupRoutes);


module.exports = router;
