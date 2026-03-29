const express = require("express");

const nutritionistController = require("../controllers/nutritionist.management.controller");
const { protect, authorize } = require("../../middleware/authMiddleware");

const router = express.Router();

// Route cho module "View Nutritionist Dashboard" (phía admin):
// - Tất cả endpoint đều yêu cầu đăng nhập và role admin.
// - Frontend trang /admin/nutritionists sẽ gọi các API này để hiển thị danh sách/chi tiết.

router.get(
  "/",
  protect,
  authorize("admin"),
  nutritionistController.getNutritionists,
);
router.get(
  "/:id",
  protect,
  authorize("admin"),
  nutritionistController.getNutritionistDetail,
);
router.post(
  "/create",
  protect,
  authorize("admin"),
  nutritionistController.createNutritionist,
);
router.put(
  "/update/:id",
  protect,
  authorize("admin"),
  nutritionistController.updateNutritionist,
);
router.delete(
  "/delete/:id",
  protect,
  authorize("admin"),
  nutritionistController.deleteNutritionist,
);

module.exports = router;
