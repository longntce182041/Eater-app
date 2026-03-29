const express = require("express");
const router = express.Router();

const nutritionistProfileController = require("../controllers/nutritionist.profile.controller");
const { protect, nutritionistOnly } = require("../../middleware/authMiddleware");

// Route cho phần "Nutritionist tự xem/cập nhật hồ sơ" trên dashboard cá nhân.
// Bắt buộc: đã đăng nhập + đúng role nutritionist.
router.use(protect, nutritionistOnly);

// Trang frontend profile gọi endpoint này để nạp dữ liệu vào form ban đầu.
router.get("/profile/me", nutritionistProfileController.getMyProfessionalProfile);
// Nút Save Profile trên frontend gọi endpoint này để upsert hồ sơ.
router.put("/profile/me", nutritionistProfileController.upsertMyProfessionalProfile);

module.exports = router;
