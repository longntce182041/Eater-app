const express = require("express");
const router = express.Router();

const nutritionistProfileController = require("../controllers/nutritionist.profile.controller");
const { protect, nutritionistOnly } = require("../../middleware/authMiddleware");

router.use(protect, nutritionistOnly);

router.get("/profile/me", nutritionistProfileController.getMyProfessionalProfile);
router.put("/profile/me", nutritionistProfileController.upsertMyProfessionalProfile);

module.exports = router;
