const healthUserService = require("../../api/services/health.user.service");

function extractUserId(user) {
  if (!user) return null;
  return user.sub || user.id || user.userId || null;
}

// New health status function
async function getHealthStatus(req, res) {
  res.status(200).json({ status: "Healthy" });
}

async function getDietaryReferences(req, res) {
  try {
    const userId = extractUserId(req.user);
    // Validate that user is authenticated
    if (!userId) {
      return res.status(401).json({
        message: "Unauthorized",
        error: "User authentication required. Please provide a valid token.",
      });
    }

    const dietaryReferences =
      await healthUserService.getUserDietaryReferences(userId);
    res.status(200).json(dietaryReferences);
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
}

async function getDietTypes(req, res) {
  try {
    const dietTypes = await healthUserService.getAllDietTypes();
    res.status(200).json(dietTypes);
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
}

async function setUserProfile(req, res) {
  try {
    const userId = extractUserId(req.user);
    // Validate that user is authenticated
    if (!userId) {
      return res.status(401).json({
        message: "Unauthorized",
        error: "User authentication required. Please provide a valid token.",
      });
    }

    const userProfile = await healthUserService.setUserProfile(
      userId,
      req.body,
    );
    res.status(200).json(userProfile);
  } catch (error) {
    res.status(500).json({ message: "Server Error", error: error.message });
  }
}

async function setDietaryReference(req, res) {
  try {
    const userId = extractUserId(req.user);
    // Validate that user is authenticated
    if (!userId) {
      return res.status(401).json({
        message: "Unauthorized",
        error: "User authentication required. Please provide a valid token.",
      });
    }

    const dietaryRef = await healthUserService.setDietaryReference(
      userId,
      req.body,
    );
    return res.status(200).json(dietaryRef);
  } catch (error) {
    return res
      .status(500)
      .json({ message: "Server Error", error: error.message });
  }
}

module.exports = {
  getDietaryReferences,
  getDietTypes,
  setUserProfile,
  setDietaryReference,
  getHealthStatus,
};
