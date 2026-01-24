const express = require("express");
const router = express.Router();
const userController = require("../controllers/user.management.controller");
const { protect, authorize } = require("../../middleware/authMiddleware");

// GET List & Create
router.get("/", userController.getUsers); // Nên thêm protect, authorize('admin')
router.post("/create", userController.createUser);

// Detail, Update, Delete theo ID
router.get("/:id", userController.getUserDetail);
router.put("/update/:id", userController.updateUser);
router.delete("/delete/:id", userController.deleteUser);

module.exports = router;