const MealLog = require("../../models/meal_log");

/**
 * Meal Log Service
 * Handles all business logic for meal logging operations
 */
class MealLogService {
  /**
   * Save a new meal log entry
   * @param {String} userId - User ID from JWT token
   * @param {Object} mealLogData - Meal log data object
   * @returns {Promise<Object>} Saved meal log with id field
   * @throws {Error} If validation fails or save fails
   */
  async saveMealLog(userId, mealLogData) {
    const {
      mealName,
      mealType,
      calories,
      protein,
      carbs,
      fats,
      quantity,
      unit,
      notes,
      loggedAt,
      mealPlanId,
      mealPlanItemId,
      imageUrl,
    } = mealLogData;

    // Validate required fields
    if (!mealName || !mealType || calories === undefined || calories === null || 
        quantity === undefined || quantity === null || !unit || !loggedAt) {
      throw new Error(
        "Missing required fields: mealName, mealType, calories, quantity, unit, loggedAt"
      );
    }

    const mealLog = new MealLog({
      userId,
      mealName,
      mealType,
      calories: Number(calories),
      protein: Number(protein) || 0,
      carbs: Number(carbs) || 0,
      fats: Number(fats) || 0,
      quantity: Number(quantity),
      unit,
      notes: notes || null,
      imageUrl: imageUrl || null,
      loggedAt: new Date(loggedAt),
      mealPlanId: mealPlanId || null,
      mealPlanItemId: mealPlanItemId || null,
    });

    await mealLog.save();

    console.log(
      `[MealLogService.saveMealLog] Saved - ID: ${mealLog._id}, userId: ${userId}, mealType: ${mealType}`
    );

    return {
      id: mealLog._id.toString(),
      ...mealLog.toObject(),
    };
  }

  /**
   * Get all meal logs for a user with pagination
   * @param {String} userId - User ID from JWT token
   * @param {Object} query - Query object with page and limit
   * @returns {Promise<Object>} Array of meal logs with pagination info
   */
  async getAllMealLogs(userId, query) {
    const page = parseInt(query.page) || 1;
    const limit = parseInt(query.limit) || 50;
    const skip = (page - 1) * limit;

    const mealLogs = await MealLog.find({ userId })
      .sort({ loggedAt: -1 })
      .skip(skip)
      .limit(limit);

    const total = await MealLog.countDocuments({ userId });

    return {
      meals: mealLogs.map((log) => ({
        id: log._id.toString(),
        ...log.toObject(),
      })),
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Get meal logs for a specific date
   * @param {String} userId - User ID from JWT token
   * @param {String} date - Date string in YYYY-MM-DD format
   * @returns {Promise<Object>} Meal logs and daily totals for the date
   */
  async getMealLogsForDate(userId, date) {
    if (!date) {
      throw new Error("Date parameter is required (format: YYYY-MM-DD)");
    }

    const startDate = new Date(date);
    startDate.setHours(0, 0, 0, 0);

    const endDate = new Date(date);
    endDate.setHours(23, 59, 59, 999);

    const mealLogs = await MealLog.find({
      userId,
      loggedAt: {
        $gte: startDate,
        $lte: endDate,
      },
    }).sort({ loggedAt: 1 });

    // Calculate daily totals
    const totals = {
      calories: 0,
      protein: 0,
      carbs: 0,
      fats: 0,
    };

    mealLogs.forEach((log) => {
      totals.calories += log.calories;
      totals.protein += log.protein;
      totals.carbs += log.carbs;
      totals.fats += log.fats;
    });

    return {
      meals: mealLogs.map((log) => ({
        id: log._id.toString(),
        ...log.toObject(),
      })),
      totals,
      date,
    };
  }

  /**
   * Get meal logs for a date range
   * @param {String} userId - User ID from JWT token
   * @param {String} startDate - Start date string in YYYY-MM-DD format
   * @param {String} endDate - End date string in YYYY-MM-DD format
   * @returns {Promise<Object>} Meal logs for the date range
   */
  async getMealLogsForDateRange(userId, startDate, endDate) {
    if (!startDate || !endDate) {
      throw new Error("Both startDate and endDate are required (format: YYYY-MM-DD)");
    }

    const start = new Date(startDate);
    start.setHours(0, 0, 0, 0);

    const end = new Date(endDate);
    end.setHours(23, 59, 59, 999);

    const mealLogs = await MealLog.find({
      userId,
      loggedAt: {
        $gte: start,
        $lte: end,
      },
    }).sort({ loggedAt: -1 });

    return {
      meals: mealLogs.map((log) => ({
        id: log._id.toString(),
        ...log.toObject(),
      })),
      count: mealLogs.length,
      dateRange: {
        startDate,
        endDate,
      },
    };
  }

  /**
   * Update a meal log entry
   * @param {String} mealLogId - Meal log ID to update
   * @param {String} userId - User ID from JWT token (for ownership verification)
   * @param {Object} updateData - Data to update
   * @returns {Promise<Object>} Updated meal log
   * @throws {Error} If not found or not authorized
   */
  async updateMealLog(mealLogId, userId, updateData) {
    if (!mealLogId) {
      throw new Error("Meal log ID is required");
    }

    const {
      mealName,
      mealType,
      calories,
      protein,
      carbs,
      fats,
      quantity,
      unit,
      notes,
      imageUrl,
    } = updateData;

    // Validate required fields
    if (!mealName || !mealType || calories === undefined || calories === null || 
        quantity === undefined || quantity === null || !unit) {
      throw new Error(
        "Missing required fields: mealName, mealType, calories, quantity, unit"
      );
    }

    // Find the meal log by ID
    let mealLog;
    try {
      mealLog = await MealLog.findById(mealLogId);
    } catch (findErr) {
      throw new Error(`Invalid meal log ID format: ${findErr.message}`);
    }

    if (!mealLog) {
      throw new Error("Meal log not found");
    }

    // Verify ownership
    if (mealLog.userId && mealLog.userId.toString() !== userId) {
      throw new Error("Not authorized to update this meal log");
    }

    // Update fields
    mealLog.mealName = mealName;
    mealLog.mealType = mealType;
    mealLog.calories = Number(calories);
    mealLog.protein = Number(protein) || 0;
    mealLog.carbs = Number(carbs) || 0;
    mealLog.fats = Number(fats) || 0;
    mealLog.quantity = Number(quantity);
    mealLog.unit = unit;
    mealLog.notes = notes || null;
    mealLog.imageUrl = imageUrl || null;

    // Set userId if not already set
    if (!mealLog.userId) {
      mealLog.userId = userId;
    }

    await mealLog.save();

    console.log(`[MealLogService.updateMealLog] Updated - ID: ${mealLogId}`);

    return {
      id: mealLog._id.toString(),
      ...mealLog.toObject(),
    };
  }

  /**
   * Delete a meal log entry
   * @param {String} mealLogId - Meal log ID to delete
   * @param {String} userId - User ID from JWT token (for ownership verification)
   * @returns {Promise<void>}
   * @throws {Error} If not found or not authorized
   */
  async deleteMealLog(mealLogId, userId) {
    if (!mealLogId) {
      throw new Error("Meal log ID is required");
    }

    const mealLog = await MealLog.findByIdAndDelete(mealLogId);

    if (!mealLog) {
      throw new Error("Meal log not found");
    }

    // Verify ownership
    if (mealLog.userId && mealLog.userId.toString() !== userId) {
      throw new Error("Not authorized to delete this meal log");
    }

    console.log(`[MealLogService.deleteMealLog] Deleted - ID: ${mealLogId}`);
  }
}

module.exports = new MealLogService();
