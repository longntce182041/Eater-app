const { Nutritionist } = require("../../models/nutritionist");

// GET /api/nutritionists/profile/me
exports.getMyProfessionalProfile = async (req, res) => {
  try {
    const userId = req.user?.id;

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
    const userId = req.user?.id;
    const { fullName, specialization, experience, certifications_url } = req.body;

    if (!fullName || !specialization || experience === undefined || experience === null) {
      return res.status(400).json({
        success: false,
        message: "fullName, specialization and experience are required",
      });
    }

    const normalizedSpecialization = String(specialization).trim();
    const specializationPattern = /^[\p{L}\s]+$/u;
    if (!specializationPattern.test(normalizedSpecialization)) {
      return res.status(400).json({
        success: false,
        message: "Specialization can only contain letters and spaces",
      });
    }

    const normalizedCerts = Array.isArray(certifications_url)
      ? certifications_url.filter((url) => typeof url === "string" && url.trim())
      : [];

    const normalizeUrl = (value) =>
      String(value).trim().toLowerCase().replace(/\/+$/, "");
    const normalizedForCompare = normalizedCerts.map(normalizeUrl);
    if (new Set(normalizedForCompare).size !== normalizedForCompare.length) {
      return res.status(400).json({
        success: false,
        message: "Duplicate certification links are not allowed",
      });
    }

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
