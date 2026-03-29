const User = require("../../models/User");
const { Nutritionist } = require("../../models/nutritionist");
const bcrypt = require("bcryptjs");

class NutritionistManagementService {
  async getAllNutritionists(query) {
    // Hàm lõi cho màn "View Nutritionist Dashboard/List":
    // - nhận filter/sort/page từ query
    // - truy vấn DB và trả về danh sách + metadata phân trang
    const {
      keyword,
      specialization,
      verified,
      minExperience,
      maxExperience,
      page = 1,
      limit = 10,
      sort = "createdAt",
      order = "desc",
    } = query;

    const filter = {};

    // Tìm kiếm theo tên hoặc chuyên môn (keyword tổng quát).
    if (keyword) {
      filter.$or = [
        { fullName: { $regex: keyword, $options: "i" } },
        { specialization: { $regex: keyword, $options: "i" } },
      ];
    }

    // Lọc chuyên môn.
    if (specialization) {
      filter.specialization = { $regex: specialization, $options: "i" };
    }

    // Lọc trạng thái verified.
    if (verified !== undefined) {
      filter.verified = String(verified).toLowerCase() === "true";
    }

    // Lọc theo khoảng năm kinh nghiệm.
    if (minExperience !== undefined || maxExperience !== undefined) {
      filter.experience = {};
      if (minExperience !== undefined) {
        filter.experience.$gte = Number(minExperience);
      }
      if (maxExperience !== undefined) {
        filter.experience.$lte = Number(maxExperience);
      }
    }

    // Tính toán phân trang và thứ tự sắp xếp.
    const currentPage = parseInt(page, 10);
    const pageSize = parseInt(limit, 10);
    const skip = (currentPage - 1) * pageSize;
    const sortOrder = String(order).toLowerCase() === "asc" ? 1 : -1;

    // Populate userId để frontend có email/role/isActive khi render bảng.
    const nutritionists = await Nutritionist.find(filter)
      .populate("userId", "email role isActive")
      .sort({ [sort]: sortOrder })
      .skip(skip)
      .limit(pageSize);

    const total = await Nutritionist.countDocuments(filter);

    return {
      nutritionists,
      total,
      page: currentPage,
      totalPages: Math.ceil(total / pageSize),
    };
  }

  async getNutritionistById(id) {
    // Dùng cho trang/ô chi tiết nutritionist.
    const nutritionist = await Nutritionist.findById(id).populate(
      "userId",
      "email role isActive",
    );

    if (!nutritionist) {
      throw new Error("Nutritionist not found");
    }

    return nutritionist;
  }

  async createNutritionist(data) {
    // Tạo user account + profile nutritionist theo mô hình 2 bảng:
    // Users (đăng nhập) và Nutritionist (thông tin nghiệp vụ).
    const email = String(data.email || "")
      .trim()
      .toLowerCase();

    const existingUser = await User.findOne({ email });
    if (existingUser) {
      throw new Error("Email already exists");
    }

    // Mã hóa mật khẩu trước khi lưu.
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(data.password, salt);

    // Tạo tài khoản đăng nhập role nutritionist.
    const user = await User.create({
      email,
      passwordHash,
      role: "nutritionist",
      isActive: true,
    });

    // Tạo profile chuyên môn gắn với user vừa tạo.
    const nutritionist = new Nutritionist({
      userId: user._id,
      fullName: data.fullName,
      specialization: data.specialization,
      experience: Number(data.experience),
      certifications_url: data.certifications_url || [],
      verified: data.verified || false,
    });

    try {
      return await nutritionist.save();
    } catch (error) {
      // Rollback user nếu lưu profile lỗi để tránh dữ liệu mồ côi.
      await User.findByIdAndDelete(user._id);
      throw error;
    }
  }

  async updateNutritionist(id, data) {
    // Cập nhật profile nutritionist hiện có.
    const nutritionist = await Nutritionist.findById(id);
    if (!nutritionist) {
      throw new Error("Nutritionist not found");
    }

    // Nếu đổi liên kết userId, phải kiểm tra:
    // - user tồn tại
    // - role đúng là nutritionist
    // - chưa bị profile khác sử dụng
    if (data.userId && String(data.userId) !== String(nutritionist.userId)) {
      const user = await User.findById(data.userId);
      if (!user) {
        throw new Error("User not found");
      }
      if (user.role !== "nutritionist") {
        throw new Error("User role must be nutritionist");
      }

      const duplicate = await Nutritionist.findOne({ userId: data.userId });
      if (duplicate && String(duplicate._id) !== String(nutritionist._id)) {
        throw new Error("Nutritionist profile already exists for this user");
      }

      nutritionist.userId = data.userId;
    }

    if (data.fullName !== undefined) {
      nutritionist.fullName = data.fullName;
    }
    if (data.specialization !== undefined) {
      nutritionist.specialization = data.specialization;
    }
    if (data.experience !== undefined) {
      nutritionist.experience = Number(data.experience);
    }
    if (data.certifications_url !== undefined) {
      nutritionist.certifications_url = data.certifications_url;
    }
    if (data.verified !== undefined) {
      nutritionist.verified = data.verified;
    }

    return nutritionist.save();
  }

  async deleteNutritionist(id) {
    // Xóa profile nutritionist (không xóa user account ở đây).
    const nutritionist = await Nutritionist.findByIdAndDelete(id);
    if (!nutritionist) {
      throw new Error("Nutritionist not found");
    }

    return nutritionist;
  }
}

module.exports = new NutritionistManagementService();
