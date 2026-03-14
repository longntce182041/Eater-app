const mongoose = require("mongoose");

const ChatMessageSchema = new mongoose.Schema(
  {
    roomId: {
      type: String,
      required: true,
      index: true,
    },
    senderId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Users",
      required: true,
    },
    senderRole: {
      type: String,
      enum: ["user", "nutritionist"],
      required: true,
    },
    content: {
      type: String,
      required: true,
      trim: true,
      maxlength: 3000,
    },
  },
  { timestamps: true }
);

// Index for efficient room history fetching
ChatMessageSchema.index({ roomId: 1, createdAt: 1 });

const ChatMessage = mongoose.model("ChatMessage", ChatMessageSchema);

module.exports = { ChatMessage };
