const User = require("../../models/User"); // Model User bạn đã có
const bcrypt = require("bcryptjs");

class UserManagementService {
  // 1. Lấy danh sách + Search + Filter
  async getAllUsers(query) {
    const { keyword, role, isActive, page = 1, limit = 10 } = query;

    // Tạo bộ lọc
    let filter = {};

    // Search theo email (gần đúng)
    if (keyword) {
      filter.email = { $regex: keyword, $options: "i" };
    }

    // Filter theo Role
    if (role) {
      filter.role = role;
    }

    // Filter theo trạng thái (Active/Inactive)
    if (isActive !== undefined) {
      filter.isActive = isActive === "true";
    }

    // Phân trang
    const skip = (parseInt(page) - 1) * parseInt(limit);

    const users = await User.find(filter)
      .select("-passwordHash") // Không trả về mật khẩu
      .skip(skip)
      .limit(parseInt(limit))
      .sort({ createdAt: -1 }); // Mới nhất lên đầu

    const total = await User.countDocuments(filter);

    return { users, total, page, totalPages: Math.ceil(total / limit) };
  }

  // 2. Xem chi tiết
  async getUserById(id) {
    const user = await User.findById(id).select("-passwordHash");
    if (!user) throw new Error("User not found");
    return user;
  }

  // 3. Tạo User mới (bởi Admin)
  async createUser(data) {
    const existingUser = await User.findOne({ email: data.email });
    if (existingUser) throw new Error("Email already exists");

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(data.password, salt);

    const newUser = new User({
      email: data.email,
      passwordHash: hashedPassword,
      role: data.role || "user",
      isActive: true,
    });

    return await newUser.save();
  }

  // 4. Update User
  async updateUser(id, data) {
    const user = await User.findById(id);
    if (!user) throw new Error("User not found");
    // 1. Cập nhật Role
    if (data.role) {
        user.role = data.role;
    }

    // 2. Cập nhật trạng thái Khóa/Mở tài khoản
    if (data.isActive !== undefined) {
        user.isActive = data.isActive;
    }

    // 3. Cập nhật trạng thái Xác thực Email (Admin verify thủ công)
    if (data.isEmailVerified !== undefined) {
        user.isEmailVerified = data.isEmailVerified;
    }
    return await user.save();
  }
  // 5. Xóa mềm (Soft Delete)
  async softDeleteUser(id) {
    const user = await User.findById(id);
    if (!user) throw new Error("User not found");

    // Chỉ đổi isActive thành false chứ không xóa khỏi DB
    user.isActive = false;
    return await user.save();
  }
}

module.exports = new UserManagementService();
