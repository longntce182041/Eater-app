const express = require("express");
const router = express.Router();
const authController = require("../controllers/auth.admin.controller");

// Định nghĩa route POST cho login admin
router.post("/login", authController.loginAdmin);

module.exports = router;