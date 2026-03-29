const { Nutritionist } = require("../../models/nutritionist");

// GET /api/nutritionists/profile/me
exports.getMyProfessionalProfile = async (req, res) => {
  try {
    // Lấy userId từ token đăng nhập hiện tại.
    const userId = req.user?.id;

    // Mỗi nutritionist có tối đa 1 profile theo userId.
    // Nếu chưa có profile, frontend sẽ hiển thị trạng thái "Create your professional profile".
    const profile = await Nutritionist.findOne({ userId });

    return res.status(200).json({
      success: true,
      data: profile,
      hasProfile: Boolean(profile),
    });
  } catch (err) {
    console.error("Error fetching nutritionist profile:", err);
    return res.status(500).json({ success: false, message: err.message });
  }
};

// PUT /api/nutritionists/profile/me
// Upsert: create profile if it does not exist, otherwise update it.
exports.upsertMyProfessionalProfile = async (req, res) => {
  try {
    // Đây là endpoint chính khi nutritionist nhấn "Save Profile" trên dashboard.
    const userId = req.user?.id;
    const { fullName, specialization, experience, certifications_url } = req.body;

    // Validate field bắt buộc để tránh lưu profile thiếu thông tin cốt lõi.
    if (!fullName || !specialization || experience === undefined || experience === null) {
      return res.status(400).json({
        success: false,
        message: "fullName, specialization and experience are required",
      });
    }

    // Chuẩn hóa specialization và giới hạn ký tự để dữ liệu sạch.
    const normalizedSpecialization = String(specialization).trim();
    const specializationPattern = /^[\p{L}\s]+$/u;
    if (!specializationPattern.test(normalizedSpecialization)) {
      return res.status(400).json({
        success: false,
        message: "Specialization can only contain letters and spaces",
      });
    }

    // Lọc các URL chứng chỉ rỗng/không hợp lệ kiểu string.
    const normalizedCerts = Array.isArray(certifications_url)
      ? certifications_url.filter((url) => typeof url === "string" && url.trim())
      : [];

    // Không cho phép link chứng chỉ trùng nhau sau khi normalize.
    const normalizeUrl = (value) =>
      String(value).trim().toLowerCase().replace(/\/+$/, "");
    const normalizedForCompare = normalizedCerts.map(normalizeUrl);
    if (new Set(normalizedForCompare).size !== normalizedForCompare.length) {
      return res.status(400).json({
        success: false,
        message: "Duplicate certification links are not allowed",
      });
    }

    // Upsert để giảm số nhánh xử lý:
    // - Có profile rồi thì update
    // - Chưa có thì tạo mới
    // Frontend luôn gọi cùng một endpoint PUT cho cả 2 trường hợp.
    const profile = await Nutritionist.findOneAndUpdate(
      { userId },
      {
        userId,
        fullName: String(fullName).trim(),
        specialization: normalizedSpecialization,
        experience: Number(experience),
        certifications_url: normalizedCerts,
      },
      { new: true, upsert: true, setDefaultsOnInsert: true }
    );

    return res.status(200).json({
      success: true,
      message: "Professional profile saved successfully",
      data: profile,
    });
  } catch (err) {
    console.error("Error upserting nutritionist profile:", err);
    return res.status(500).json({ success: false, message: err.message });
  }
};
