const healthUserService = require("../../api/services/health.user.service");

async function getDietaryReferences(req, res) {
  try {
    const userId = req.user.id;
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

module.exports = {
  getDietaryReferences,
  getDietTypes,
  getHealthStatus, // Export the new function
};

// New health status function
async function getHealthStatus(req, res) {
  res.status(200).json({ status: "Healthy" });
}
