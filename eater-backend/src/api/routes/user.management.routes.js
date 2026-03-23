const express = require("express");
const router = express.Router();
const userController = require("../controllers/user.management.controller");
const { protect, authorize } = require("../../middleware/authMiddleware");

// GET List & Create
router.get("/",protect, authorize('admin', 'nutritionist'), userController.getUsers);
router.post("/create",protect, authorize('admin'), userController.createUser);

// Detail, Update, Delete theo ID
router.get("/:id",protect, authorize('admin'), userController.getUserDetail);
router.put("/update/:id",protect, authorize('admin'), userController.updateUser);
router.delete("/delete/:id",protect, authorize('admin'), userController.deleteUser);

module.exports = router;