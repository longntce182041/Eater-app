const User = require("../../models/User");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

class AuthAdminService {
  async loginAdmin(email, password) {
    // 1. Tìm user theo email
    const user = await User.findOne({ email });

    if (!user) {
      throw new Error("User not found");
    }

    // 2. Kiểm tra Role (Quan trọng: Chỉ cho phép Admin)
    if (user.role !== "admin") {
      throw new Error("Access denied. You are not an Admin.");
    }

    // 3. So sánh mật khẩu (Input password vs Hash password trong DB)
    const isMatch = await bcrypt.compare(password, user.passwordHash);
    if (!isMatch) {
      throw new Error("Invalid credentials");
    }

    // 4. Tạo JWT Token
    const payload = {
      userId: user._id,
      role: user.role,
    };

    const token = jwt.sign(payload, process.env.JWT_SECRET || "secret_key", {
      expiresIn: process.env.JWT_EXPIRE || "1d",
    });

    // 5. Trả về thông tin (không trả passwordHash)
    return {
      token,
      user: {
        id: user._id,
        email: user.email,
        role: user.role,
        isActive: user.isActive,
      },
    };
  }
}

module.exports = new AuthAdminService();
