const express = require("express");
const healthController = require("../controllers/health.controller");
const { validateRequest } = require("../../middleware/validateRequest");
const {
  updateHealthInfoSchema,
  createHealthInfoSchema,
} = require("../validators/health.validators");

const router = express.Router();

// GET /api/v1/health/:userId
router.get("/:userId", healthController.getHealthInfo);

// POST /api/v1/health/:userId (create health info)
router.post(
  "/:userId",
  validateRequest(createHealthInfoSchema),
  healthController.createHealthInfo,
);

// PUT /api/v1/health/:userId (update health info)
router.put(
  "/:userId",
  validateRequest(updateHealthInfoSchema),
  healthController.updateHealthInfo,
);

// DELETE /api/v1/health/:userId
router.delete("/:userId", healthController.deleteHealthInfo);

// GET /api/v1/health/diet-types (get available diet types)
router.get("/diet-types", healthController.getDietTypes);

// PATCH /api/v1/health/:userId/dietary-preferences
router.patch(
  "/:userId/dietary-preferences",
  healthController.setDietaryPreferences,
);

// PATCH /api/v1/health/:userId/allergies
router.patch("/:userId/allergies", healthController.setAllergies);

// PATCH /api/v1/health/:userId/dislikes
router.patch("/:userId/dislikes", healthController.setDislikesIngredients);

module.exports = router;
