const jwt = require("jsonwebtoken");
const { jwtConfig } = require("../../config/jwt");
const { ChatMessage } = require("../../models/chat_message");
const { Nutritionist } = require("../../models/nutritionist");

/**
 * Derive a stable room ID from two user IDs (sorted so order doesn't matter).
 */
function getRoomId(userIdA, userIdB) {
  const sorted = [userIdA.toString(), userIdB.toString()].sort();
  return sorted.join("_");
}

function setupChatSocket(io) {
  // ── Auth middleware ──────────────────────────────────────────────────────
  io.use((socket, next) => {
    const token =
      socket.handshake.query?.token || socket.handshake.auth?.token;
    if (!token) return next(new Error("Authentication error"));

    try {
      const payload = jwt.verify(token, jwtConfig.secret);
      socket.userId = payload.id || payload.sub || payload.userId;
      socket.userRole = payload.role;
      next();
    } catch {
      next(new Error("Authentication error"));
    }
  });

  // ── Connection ───────────────────────────────────────────────────────────
  io.on("connection", (socket) => {
    console.log(`[Socket] Connected: ${socket.userId} (${socket.userRole})`);

    /**
     * Client emits join_room with { nutritionistId } (Nutritionist document _id).
     * Server looks up the nutritionist's userId, forms roomId, joins the room.
     */
    socket.on("join_room", async ({ nutritionistId }) => {
      try {
        const nutritionist = await Nutritionist.findById(nutritionistId);
        if (!nutritionist) {
          socket.emit("error", { message: "Nutritionist not found" });
          return;
        }

        const roomId = getRoomId(
          socket.userId,
          nutritionist.userId.toString()
        );

        // Leave any previously joined room
        if (socket.currentRoomId && socket.currentRoomId !== roomId) {
          socket.leave(socket.currentRoomId);
        }

        socket.join(roomId);
        socket.currentRoomId = roomId;
        socket.emit("room_joined", { roomId });
      } catch (err) {
        socket.emit("error", { message: err.message });
      }
    });

    /**
     * Nutritionist emits join_room_user with { userId } (the user's account _id).
     * socket.userId IS the nutritionist's account ID — no DB lookup needed.
     */
    socket.on("join_room_user", ({ userId }) => {
      if (socket.userRole !== "nutritionist" && socket.userRole !== "admin") {
        socket.emit("error", { message: "Only nutritionists can use this event" });
        return;
      }

      if (!userId) {
        socket.emit("error", { message: "userId is required" });
        return;
      }

      // Room = sorted(nutritionistUserId, userUserId)  — same formula as join_room
      const roomId = getRoomId(userId, socket.userId);

      if (socket.currentRoomId && socket.currentRoomId !== roomId) {
        socket.leave(socket.currentRoomId);
      }

      socket.join(roomId);
      socket.currentRoomId = roomId;
      socket.emit("room_joined", { roomId });
    });

    /**
     * Client emits send_message with { content }.
     * Message is persisted and broadcast to everyone in the room.
     */
    socket.on("send_message", async ({ content }) => {
      try {
        if (!socket.currentRoomId || !content?.trim()) return;

        const msg = await ChatMessage.create({
          roomId: socket.currentRoomId,
          senderId: socket.userId,
          senderRole:
            socket.userRole === "nutritionist" ? "nutritionist" : "user",
          content: content.trim(),
        });

        const outgoing = {
          id: msg._id,
          senderId: msg.senderId,
          senderRole: msg.senderRole,
          content: msg.content,
          createdAt: msg.createdAt,
        };

        io.to(socket.currentRoomId).emit("receive_message", outgoing);
      } catch (err) {
        socket.emit("error", { message: err.message });
      }
    });

    socket.on("leave_room", () => {
      if (socket.currentRoomId) {
        socket.leave(socket.currentRoomId);
        socket.currentRoomId = null;
      }
    });

    socket.on("disconnect", () => {
      console.log(`[Socket] Disconnected: ${socket.userId}`);
    });
  });
}

module.exports = { setupChatSocket, getRoomId };
