const mongoose = require("mongoose");

const UserSchema = new mongoose.Schema(
  {
    email: {
      type: String,
      unique: true,
      required: true,
      lowercase: true,
      trim: true,
    },
    passwordHash: { type: String, required: true },
    role: {
      type: String,
      enum: ["user", "admin", "nutritionist"],
      default: "user",
    },
    isActive: { type: Boolean, default: true },
    isEmailVerified: { type: Boolean, default: false },
    passwordResetOtp: { type: String, default: null },
    passwordResetOtpExpires: { type: Date, default: null },
  },
  { timestamps: true },
);

const User = mongoose.model("Users", UserSchema);

module.exports = User;
