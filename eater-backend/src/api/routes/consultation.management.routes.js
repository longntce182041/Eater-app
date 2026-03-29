const express = require("express");
const router = express.Router();
const consultationController = require("../controllers/consultation.management.controller");
const { protect, authorize } = require("../../middleware/authMiddleware");

// Yêu cầu đăng nhập VÀ bắt buộc phải là 'nutritionist' 
router.use(protect);
router.use(authorize('nutritionist'));

// Task: Diagnose Nutrition Condition + Send Recommendations
// 1. Chẩn đoán & Khuyến nghị
router.post("/diagnose", consultationController.createConsultation);

// Task: Create Personalized Diet Plan + Assign Meal Plan To User
// 2. Tạo & Gán Meal Plan cá nhân
router.post("/meal-plans", consultationController.createMealPlan);

// Task: Generate Nutrition Recommendations & Reports
// 3. Xuất Báo cáo cho 1 User
router.get("/reports/:patientId", consultationController.getNutritionReport);

// Task: View User Health Data
// 4. Nutritionist xem dữ liệu sức khỏe user
router.get("/users/:patientId/health-data", consultationController.getUserHealthData);

module.exports = router;