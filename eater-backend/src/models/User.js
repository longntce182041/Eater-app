const mongoose = require("mongoose");

const UserSchema = new mongoose.Schema(
  {
    email: { type: String, unique: true, required: true, lowercase: true, trim: true },
    passwordHash: { type: String, required: true },
    role: {
      type: String,
      enum: ["user", "admin", "nutritionist"],
      default: "user",
    },
    isActive: { type: Boolean, default: true },
    isEmailVerified: { type: Boolean, default: false },
    emailVerificationToken: { type: String, default: null },
    emailVerificationTokenExpires: { type: Date, default: null },
    passwordResetToken: { type: String, default: null },
    passwordResetTokenExpires: { type: Date, default: null },
  },
  { timestamps: true },
);

// Index for faster lookups
UserSchema.index({ email: 1 });
UserSchema.index({ emailVerificationToken: 1 });
UserSchema.index({ passwordResetToken: 1 });

const User = mongoose.model("Users", UserSchema);

module.exports = User;
