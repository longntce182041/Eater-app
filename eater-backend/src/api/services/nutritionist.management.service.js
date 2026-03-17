const User = require("../../models/User");
const { Nutritionist } = require("../../models/nutritionist");
const bcrypt = require("bcryptjs");

class NutritionistManagementService {
  async getAllNutritionists(query) {
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

    if (keyword) {
      filter.$or = [
        { fullName: { $regex: keyword, $options: "i" } },
        { specialization: { $regex: keyword, $options: "i" } },
      ];
    }

    if (specialization) {
      filter.specialization = { $regex: specialization, $options: "i" };
    }

    if (verified !== undefined) {
      filter.verified = String(verified).toLowerCase() === "true";
    }

    if (minExperience !== undefined || maxExperience !== undefined) {
      filter.experience = {};
      if (minExperience !== undefined) {
        filter.experience.$gte = Number(minExperience);
      }
      if (maxExperience !== undefined) {
        filter.experience.$lte = Number(maxExperience);
      }
    }

    const currentPage = parseInt(page, 10);
    const pageSize = parseInt(limit, 10);
    const skip = (currentPage - 1) * pageSize;
    const sortOrder = String(order).toLowerCase() === "asc" ? 1 : -1;

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
    const email = String(data.email || "")
      .trim()
      .toLowerCase();

    const existingUser = await User.findOne({ email });
    if (existingUser) {
      throw new Error("Email already exists");
    }

    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(data.password, salt);

    const user = await User.create({
      email,
      passwordHash,
      role: "nutritionist",
      isActive: true,
    });

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
      await User.findByIdAndDelete(user._id);
      throw error;
    }
  }

  async updateNutritionist(id, data) {
    const nutritionist = await Nutritionist.findById(id);
    if (!nutritionist) {
      throw new Error("Nutritionist not found");
    }

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
    const nutritionist = await Nutritionist.findByIdAndDelete(id);
    if (!nutritionist) {
      throw new Error("Nutritionist not found");
    }

    return nutritionist;
  }
}

module.exports = new NutritionistManagementService();
