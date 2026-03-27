const mealLogService = require("../services/meal.log.service");

/**
 * @controller Save meal log
 * @desc Save a meal log entry when user marks meal as eaten
 * @param {Request} req - Express request object with meal log data in req.body
 * @param {Response} res - Express response object
 * @param {Function} next - Express next middleware function
 */
async function saveMealLog(req, res, next) {
  try {
    const userId = req.user.sub; // From JWT token
    console.log(`[saveMealLog] Creating meal - userId: ${userId}, mealName: ${req.body.mealName}`);

    const mealLog = await mealLogService.saveMealLog(userId, req.body);

    return res.status(201).json({
      status: "success",
      message: "Meal logged successfully",
      data: mealLog,
    });
  } catch (err) {
    console.error(`[saveMealLog] Error:`, err.message);
    return res.status(400).json({
      status: "error",
      message: err.message,
    });
  }
}

/**
 * @controller Get meal logs for a date
 * @desc Retrieve meal logs for a specific date
 * @param {Request} req - Express request with date query parameter
 * @param {Response} res - Express response object
 * @param {Function} next - Express next middleware function
 */
async function getMealLogsForDate(req, res, next) {
  try {
    const userId = req.user.sub;
    const { date } = req.query; // format: YYYY-MM-DD

    const result = await mealLogService.getMealLogsForDate(userId, date);

    return res.status(200).json({
      status: "success",
      message: "Meal logs retrieved successfully",
      data: result,
    });
  } catch (err) {
    console.error(`[getMealLogsForDate] Error:`, err.message);
    return res.status(400).json({
      status: "error",
      message: err.message,
    });
  }
}

/**
 * @controller Get meal logs for a date range
 * @desc Retrieve meal logs for a specific date range
 * @param {Request} req - Express request with startDate and endDate query parameters
 * @param {Response} res - Express response object
 * @param {Function} next - Express next middleware function
 */
async function getMealLogsForDateRange(req, res, next) {
  try {
    const userId = req.user.sub;
    const { startDate, endDate } = req.query;

    const result = await mealLogService.getMealLogsForDateRange(userId, startDate, endDate);

    return res.status(200).json({
      status: "success",
      message: "Meal logs retrieved successfully",
      data: result,
    });
  } catch (err) {
    console.error(`[getMealLogsForDateRange] Error:`, err.message);
    return res.status(400).json({
      status: "error",
      message: err.message,
    });
  }
}

/**
 * @controller Update meal log
 * @desc Update a specific meal log entry
 * @param {Request} req - Express request with mealLogId in params
 * @param {Response} res - Express response object
 * @param {Function} next - Express next middleware function
 */
async function updateMealLog(req, res, next) {
  try {
    const userId = req.user.sub;
    const { mealLogId } = req.params;

    console.log(`[updateMealLog] Updating - userId: ${userId}, mealLogId: ${mealLogId}`);

    const mealLog = await mealLogService.updateMealLog(mealLogId, userId, req.body);

    return res.status(200).json({
      status: "success",
      message: "Meal log updated successfully",
      data: mealLog,
    });
  } catch (err) {
    console.error(`[updateMealLog] Error:`, err.message);
    const statusCode = err.message.includes("not found") ? 404 : 
                       err.message.includes("Not authorized") ? 403 : 400;
    return res.status(statusCode).json({
      status: "error",
      message: err.message,
    });
  }
}

/**
 * @controller Delete meal log
 * @desc Delete a specific meal log entry
 * @param {Request} req - Express request with mealLogId in params
 * @param {Response} res - Express response object
 * @param {Function} next - Express next middleware function
 */
async function deleteMealLog(req, res, next) {
  try {
    const userId = req.user.sub;
    const { mealLogId } = req.params;

    console.log(`[deleteMealLog] Deleting - userId: ${userId}, mealLogId: ${mealLogId}`);

    await mealLogService.deleteMealLog(mealLogId, userId);

    return res.status(200).json({
      status: "success",
      message: "Meal log deleted successfully",
    });
  } catch (err) {
    console.error(`[deleteMealLog] Error:`, err.message);
    const statusCode = err.message.includes("not found") ? 404 : 
                       err.message.includes("Not authorized") ? 403 : 400;
    return res.status(statusCode).json({
      status: "error",
      message: err.message,
    });
  }
}

/**
 * @controller Get all meal logs for user
 * @desc Retrieve all meal logs for the current user with pagination
 * @param {Request} req - Express request with optional page and limit query parameters
 * @param {Response} res - Express response object
 * @param {Function} next - Express next middleware function
 */
/**
 * @controller Get all meal logs for user
 * @desc Retrieve all meal logs for the current user with pagination
 * @param {Request} req - Express request with optional page and limit query parameters
 * @param {Response} res - Express response object
 * @param {Function} next - Express next middleware function
 */
async function getAllMealLogs(req, res, next) {
  try {
    const userId = req.user.sub;

    const result = await mealLogService.getAllMealLogs(userId, req.query);

    return res.status(200).json({
      status: "success",
      message: "Meal logs retrieved successfully",
      data: result,
    });
  } catch (err) {
    console.error(`[getAllMealLogs] Error:`, err.message);
    return res.status(400).json({
      status: "error",
      message: err.message,
    });
  }
}

module.exports = {
  saveMealLog,
  getMealLogsForDate,
  getMealLogsForDateRange,
  updateMealLog,
  deleteMealLog,
  getAllMealLogs,
};
