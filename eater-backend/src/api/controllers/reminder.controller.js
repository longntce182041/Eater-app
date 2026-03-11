const reminderService = require("../services/reminder.service");

const VALID_MEAL_TYPES = ["breakfast", "lunch", "dinner", "snack"];

function formatReminder(r) {
  return {
    id: r._id,
    mealType: r.mealType,
    time: r.time,
    days: r.days,
    enabled: r.enabled,
    label: r.label || null,
    updatedAt: r.updatedAt,
  };
}

/**
 * GET /api/reminders
 * Fetch all reminders for the authenticated user.
 */
exports.getAll = async (req, res) => {
  try {
    const userId = req.user?.id;
    if (!userId) {
      return res.status(401).json({ success: false, message: "Authentication required", code: "UNAUTHORIZED" });
    }

    const reminders = await reminderService.getAll(userId);
    return res.json({
      success: true,
      data: reminders.map(formatReminder),
    });
  } catch (error) {
    console.error("Error fetching reminders:", error);
    return res.status(500).json({
      success: false,
      message: error.message || "Failed to fetch reminders",
      code: error.code || "FETCH_REMINDERS_ERROR",
    });
  }
};

/**
 * PUT /api/reminders/:mealType
 * Create or update a reminder.
 */
exports.upsert = async (req, res) => {
  try {
    const userId = req.user?.id;
    if (!userId) {
      return res.status(401).json({ success: false, message: "Authentication required", code: "UNAUTHORIZED" });
    }

    const { mealType } = req.params;
    if (!VALID_MEAL_TYPES.includes(mealType)) {
      return res.status(400).json({
        success: false,
        message: `Invalid meal type. Must be one of: ${VALID_MEAL_TYPES.join(", ")}`,
        code: "INVALID_MEAL_TYPE",
      });
    }

    const { time, days, enabled, label } = req.body;

    if (!time || !/^([01]\d|2[0-3]):([0-5]\d)$/.test(time)) {
      return res.status(400).json({
        success: false,
        message: "Invalid time format. Use HH:mm (24-hour), e.g. '07:30'",
        code: "INVALID_TIME_FORMAT",
      });
    }

    if (days !== undefined && (!Array.isArray(days) || days.some((d) => d < 0 || d > 6))) {
      return res.status(400).json({
        success: false,
        message: "Invalid days. Must be array of integers 0-6 (0=Sunday)",
        code: "INVALID_DAYS",
      });
    }

    const reminder = await reminderService.upsert(userId, mealType, {
      time,
      days: days ?? [1, 2, 3, 4, 5, 6, 0],
      enabled: enabled !== undefined ? Boolean(enabled) : true,
      label: label || undefined,
    });

    return res.json({ success: true, data: formatReminder(reminder) });
  } catch (error) {
    console.error("Error upserting reminder:", error);
    return res.status(error.statusCode || 500).json({
      success: false,
      message: error.message || "Failed to save reminder",
      code: error.code || "UPSERT_REMINDER_ERROR",
    });
  }
};

/**
 * PATCH /api/reminders/:mealType/toggle
 * Toggle enabled/disabled for a reminder.
 */
exports.toggle = async (req, res) => {
  try {
    const userId = req.user?.id;
    if (!userId) {
      return res.status(401).json({ success: false, message: "Authentication required", code: "UNAUTHORIZED" });
    }

    const { mealType } = req.params;
    if (!VALID_MEAL_TYPES.includes(mealType)) {
      return res.status(400).json({
        success: false,
        message: `Invalid meal type. Must be one of: ${VALID_MEAL_TYPES.join(", ")}`,
        code: "INVALID_MEAL_TYPE",
      });
    }

    const reminder = await reminderService.toggle(userId, mealType);
    return res.json({ success: true, data: formatReminder(reminder) });
  } catch (error) {
    console.error("Error toggling reminder:", error);
    return res.status(error.statusCode || 500).json({
      success: false,
      message: error.message || "Failed to toggle reminder",
      code: error.code || "TOGGLE_REMINDER_ERROR",
    });
  }
};

/**
 * DELETE /api/reminders/:mealType
 * Remove a reminder.
 */
exports.remove = async (req, res) => {
  try {
    const userId = req.user?.id;
    if (!userId) {
      return res.status(401).json({ success: false, message: "Authentication required", code: "UNAUTHORIZED" });
    }

    const { mealType } = req.params;
    if (!VALID_MEAL_TYPES.includes(mealType)) {
      return res.status(400).json({
        success: false,
        message: `Invalid meal type. Must be one of: ${VALID_MEAL_TYPES.join(", ")}`,
        code: "INVALID_MEAL_TYPE",
      });
    }

    await reminderService.remove(userId, mealType);
    return res.json({ success: true, message: "Reminder deleted successfully" });
  } catch (error) {
    console.error("Error deleting reminder:", error);
    return res.status(error.statusCode || 500).json({
      success: false,
      message: error.message || "Failed to delete reminder",
      code: error.code || "DELETE_REMINDER_ERROR",
    });
  }
};
