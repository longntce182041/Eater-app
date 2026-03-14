const mongoose = require("mongoose");

const ConsultationReplySchema = new mongoose.Schema(
  {
    consultationId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "ConsultationRequest",
      required: true,
    },
    senderId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Users",
      required: true,
    },
    senderRole: {
      type: String,
      enum: ["user", "nutritionist", "admin"],
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

const ConsultationReply = mongoose.model(
  "ConsultationReply",
  ConsultationReplySchema
);

module.exports = { ConsultationReply };
