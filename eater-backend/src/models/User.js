const mongoose = require("mongoose");

const UserSchema = new mongoose.Schema(
  {
    email: { type: String, unique: true, required: true },
    passwordHash: { type: String, required: true },
    role: {
      type: String,
      enum: ["user", "admin", "nutritionist"],
      default: "user",
    },
    isActive: { type: Boolean, default: true },
  },
  { timestamps: true },
);

const User = mongoose.model("Users", UserSchema);

module.exports = User;
