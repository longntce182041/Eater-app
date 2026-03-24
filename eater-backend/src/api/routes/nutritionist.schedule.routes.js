const express = require("express");
const router = express.Router();
const nutritionistScheduleController = require("../controllers/nutritionist.schedule.controller");
const { protect, adminOnly, nutritionistOnly } = require("../../middleware/authMiddleware");

// ===== Specific routes FIRST (before parameterized routes) =====

// Admin: Get all schedules
router.get("/all", protect, adminOnly, nutritionistScheduleController.getAllSchedules);

// Admin: Get all nutritionists for schedule assignment
router.get("/nutritionists", protect, adminOnly, nutritionistScheduleController.getNutritionistsForScheduling);

// Get nutritionist's own schedule
router.get("/my-schedule", protect, nutritionistScheduleController.getNutritionistSchedule);

// ===== Schedule Change Requests (specific routes first) =====

// Admin: Get all pending change requests
router.get("/change-requests/all", protect, adminOnly, nutritionistScheduleController.getAllChangeRequests);

// Nutritionist: Request schedule change
router.post("/change-requests/request", protect, nutritionistScheduleController.requestScheduleChange);

// Get change requests for a nutritionist (Nutritionist or Admin)
router.get(
  "/change-requests/nutritionist/:nutritionistId",
  protect,
  nutritionistScheduleController.getNutritionistChangeRequests
);

// Admin: Approve change request
router.patch("/change-requests/:requestId/approve", protect, adminOnly, nutritionistScheduleController.approveChangeRequest);

// Admin: Reject change request
router.patch("/change-requests/:requestId/reject", protect, adminOnly, nutritionistScheduleController.rejectChangeRequest);

// ===== Generic routes LAST =====

// Admin: Create schedule for nutritionist
router.post("/", protect, adminOnly, nutritionistScheduleController.createSchedule);

// Get nutritionist's schedule (for viewing by ID)
router.get("/nutritionist/:nutritionistId", protect, nutritionistScheduleController.getNutritionistSchedule);

// Get schedule by ID
router.get("/:scheduleId", protect, nutritionistScheduleController.getScheduleById);

// Update schedule (Admin)
router.put("/:scheduleId", protect, adminOnly, nutritionistScheduleController.updateSchedule);

// Delete schedule (Admin)
router.delete("/:scheduleId", protect, adminOnly, nutritionistScheduleController.deleteSchedule);

module.exports = router;
