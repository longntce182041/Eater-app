const express = require("express");
const mealLogController = require("../controllers/meal.log.controller");
const { protect } = require("../../middleware/authMiddleware");

const router = express.Router();

// All routes require authentication
router.use(protect);

/**
 * @route   POST /api/meal-logs
 * @desc    Save a new meal log entry
 * @access  Private
 */
router.post("/", mealLogController.saveMealLog);

/**
 * @route   GET /api/meal-logs
 * @desc    Get all meal logs for current user (with pagination)
 * @access  Private
 */
router.get("/", mealLogController.getAllMealLogs);

/**
 * SPECIFIC ROUTES FIRST (before :id routes)
 * This ensures /date/:date and /range/:startDate/:endDate match before /:mealLogId
 */

/**
 * @route   GET /api/meal-logs/date/:date
 * @desc    Get meal logs for a specific date (YYYY-MM-DD format)
 * @access  Private
 */
router.get("/date/:date", mealLogController.getMealLogsForDate);

/**
 * @route   GET /api/meal-logs/range/:startDate/:endDate
 * @desc    Get meal logs for a date range
 * @access  Private
 */
router.get("/range/:startDate/:endDate", mealLogController.getMealLogsForDateRange);

/**
 * GENERIC ROUTES LAST (:id routes)
 * These should be at the end to avoid shadowing specific routes
 */

/**
 * @route   PUT /api/meal-logs/:mealLogId
 * @desc    Update a specific meal log entry
 * @access  Private
 */
router.put("/:mealLogId", mealLogController.updateMealLog);

/**
 * @route   PATCH /api/meal-logs/:mealLogId
 * @desc    Update a specific meal log entry (alternative to PUT)
 * @access  Private
 */
router.patch("/:mealLogId", mealLogController.updateMealLog);

/**
 * @route   DELETE /api/meal-logs/:mealLogId
 * @desc    Delete a specific meal log entry
 * @access  Private
 */
router.delete("/:mealLogId", mealLogController.deleteMealLog);

module.exports = router;
