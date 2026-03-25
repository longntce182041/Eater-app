const updateProService = require("../api/services/updatePro.service");

async function loadProStatus(req, res, next) {
  try {
    const userId = req.user?.id || req.user?.sub || req.user?.userId;
    if (!userId) {
      return res.status(401).json({ message: "Not authenticated" });
    }

    req.proStatus = await updateProService.getProStatus(userId);
    return next();
  } catch (error) {
    return res.status(error.statusCode || 500).json({
      message: error.message || "Failed to load Pro status",
    });
  }
}

async function requirePro(req, res, next) {
  try {
    const role = req.user?.role;
    if (role === "admin" || role === "nutritionist") {
      return next();
    }

    if (!req.proStatus) {
      const userId = req.user?.id || req.user?.sub || req.user?.userId;
      if (!userId) {
        return res.status(401).json({ message: "Not authenticated" });
      }
      req.proStatus = await updateProService.getProStatus(userId);
    }

    if (!req.proStatus?.isPro) {
      return res.status(403).json({
        message: "This feature requires an active Pro subscription",
      });
    }

    return next();
  } catch (error) {
    return res.status(error.statusCode || 500).json({
      message: error.message || "Failed to verify Pro access",
    });
  }
}

module.exports = {
  loadProStatus,
  requirePro,
};
