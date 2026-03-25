const { ChatMessage } = require("../../models/chat_message");
const { Nutritionist } = require("../../models/nutritionist");
const User = require("../../models/User");
const { getRoomId } = require("../sockets/chat.socket");

/**
 * GET /api/chat/:nutritionistId/messages
 * Returns message history between the logged-in user and a nutritionist.
 * Query: page (default 1), limit (default 50)
 */
async function getChatHistory(req, res, next) {
  try {
    const { nutritionistId } = req.params;
    const userId = req.user.id;
    const page = Math.max(1, parseInt(req.query.page) || 1);
    const limit = Math.min(100, parseInt(req.query.limit) || 50);

    const nutritionist = await Nutritionist.findById(nutritionistId);
    if (!nutritionist) {
      return res
        .status(404)
        .json({ success: false, message: "Nutritionist not found" });
    }

    const roomId = getRoomId(userId, nutritionist.userId.toString());
    const skip = (page - 1) * limit;

    const [messages, total] = await Promise.all([
      ChatMessage.find({ roomId })
        .sort({ createdAt: 1 })
        .skip(skip)
        .limit(limit),
      ChatMessage.countDocuments({ roomId }),
    ]);

    return res.json({
      success: true,
      data: {
        messages: messages.map((m) => ({
          id: m._id,
          senderId: m.senderId,
          senderRole: m.senderRole,
          content: m.content,
          createdAt: m.createdAt,
        })),
        total,
        page,
        limit,
      },
    });
  } catch (err) {
    next(err);
  }
}

/**
 * GET /api/chat/contacts
 * For nutritionist: returns list of users they have chatted with (from ChatMessage rooms).
 */
async function getContacts(req, res, next) {
  try {
    const nutritionistUserId = req.user.id;

    // Get all distinct roomIds involving this nutritionist
    const rooms = await ChatMessage.distinct("roomId", {
      roomId: { $regex: nutritionistUserId.toString() },
    });

    const userIds = [];
    for (const roomId of rooms) {
      const parts = roomId.split("_");
      const otherUserId = parts.find(
        (p) => p !== nutritionistUserId.toString(),
      );
      if (otherUserId && !userIds.includes(otherUserId)) {
        userIds.push(otherUserId);
      }
    }

    // Look up user emails
    const users = await Promise.all(
      userIds.map(async (uid) => {
        const user = await User.findById(uid).select("email _id");
        return user ? { id: user._id, email: user.email } : null;
      }),
    );

    return res.json({
      success: true,
      data: users.filter(Boolean),
    });
  } catch (err) {
    next(err);
  }
}

/**
 * GET /api/chat/nutritionists
 * For users: returns list of verified nutritionists to start a chat with.
 */
async function getNutritionists(req, res, next) {
  try {
    const nutritionists = await Nutritionist.find({ verified: true }).select(
      "fullName specialization experience userId",
    );

    const data = await Promise.all(
      nutritionists.map(async (n) => {
        const user = await User.findById(n.userId).select("email");
        return {
          id: n._id,
          fullName: n.fullName,
          specialization: n.specialization,
          experience: n.experience,
          email: user?.email ?? null,
        };
      }),
    );

    return res.json({ success: true, data });
  } catch (err) {
    next(err);
  }
}

/**
 * GET /api/chat/user/:userId/messages
 * For nutritionist: returns chat history with a specific user.
 */
async function getNutritionistChatHistory(req, res, next) {
  try {
    const nutritionistUserId = req.user.id;
    const { userId } = req.params;
    const page = Math.max(1, parseInt(req.query.page) || 1);
    const limit = Math.min(100, parseInt(req.query.limit) || 50);

    const roomId = getRoomId(nutritionistUserId, userId);
    const skip = (page - 1) * limit;

    const [messages, total] = await Promise.all([
      ChatMessage.find({ roomId })
        .sort({ createdAt: 1 })
        .skip(skip)
        .limit(limit),
      ChatMessage.countDocuments({ roomId }),
    ]);

    return res.json({
      success: true,
      data: {
        messages: messages.map((m) => ({
          id: m._id,
          senderId: m.senderId,
          senderRole: m.senderRole,
          content: m.content,
          createdAt: m.createdAt,
        })),
        total,
        page,
        limit,
      },
    });
  } catch (err) {
    next(err);
  }
}

module.exports = {
  getChatHistory,
  getContacts,
  getNutritionistChatHistory,
  getNutritionists,
};
