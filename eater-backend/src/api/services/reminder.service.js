const { UserReminder } = require("../../models/user_reminder");

/**
 * Get all reminders for a user.
 * Returns up to 4 reminders (one per meal type).
 */
async function getAll(userId) {
  return UserReminder.find({ userId }).sort({ mealType: 1 });
}

/**
 * Create or update a reminder for a specific meal type.
 */
async function upsert(userId, mealType, { time, days, enabled, label }) {
  return UserReminder.findOneAndUpdate(
    { userId, mealType },
    { time, days, enabled, label },
    { upsert: true, new: true, setDefaultsOnInsert: true, runValidators: true }
  );
}

/**
 * Toggle the enabled flag for a reminder.
 */
async function toggle(userId, mealType) {
  const reminder = await UserReminder.findOne({ userId, mealType });
  if (!reminder) {
    const error = new Error("Reminder not found");
    error.statusCode = 404;
    error.code = "REMINDER_NOT_FOUND";
    throw error;
  }
  reminder.enabled = !reminder.enabled;
  return reminder.save();
}

/**
 * Delete a reminder for a specific meal type.
 */
async function remove(userId, mealType) {
  const result = await UserReminder.findOneAndDelete({ userId, mealType });
  if (!result) {
    const error = new Error("Reminder not found");
    error.statusCode = 404;
    error.code = "REMINDER_NOT_FOUND";
    throw error;
  }
  return result;
}

module.exports = { getAll, upsert, toggle, remove };
