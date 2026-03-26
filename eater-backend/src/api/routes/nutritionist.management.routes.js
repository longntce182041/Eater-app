const express = require("express");

const nutritionistController = require("../controllers/nutritionist.management.controller");
const { protect, authorize } = require("../../middleware/authMiddleware");

const router = express.Router();

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
