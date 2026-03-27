const updateProService = require("../services/updatePro.service");

async function createProCheckout(req, res) {
  try {
    const userId = req.user?.id || req.user?.sub || req.user?.userId;
    const result = await updateProService.createProCheckout(
      userId,
      req.body || {},
    );

    return res.status(201).json({
      success: true,
      message: "Created PayOS payment link",
      data: result,
    });
  } catch (error) {
    console.error("Error creating Pro checkout:", error);
    return res.status(error.statusCode || 500).json({
      success: false,
      message: error.message || "Failed to create payment link",
    });
  }
}

async function handlePayOSWebhook(req, res) {
  try {
    let payload = req.body;
    // If body is a Buffer (from express.raw), parse it
    if (Buffer.isBuffer(payload)) {
      payload = JSON.parse(payload.toString("utf8"));
    }
    const result = await updateProService.handlePayOSWebhook(payload);

    return res.status(200).json({
      success: true,
      message: "Webhook processed",
      data: result,
    });
  } catch (error) {
    console.error("Error processing PayOS webhook:", error);
    return res.status(error.statusCode || 500).json({
      success: false,
      message: error.message || "Webhook processing failed",
    });
  }
}

async function getProStatus(req, res) {
  try {
    const result =
      req.proStatus ||
      (await updateProService.getProStatus(
        req.user?.id || req.user?.sub || req.user?.userId,
      ));

    return res.status(200).json({
      success: true,
      data: result,
    });
  } catch (error) {
    console.error("Error getting Pro status:", error);
    return res.status(error.statusCode || 500).json({
      success: false,
      message: error.message || "Failed to fetch Pro status",
    });
  }
}

async function getProPlans(req, res) {
  try {
    const result = updateProService.getProPlans();

    return res.status(200).json({
      success: true,
      data: result,
    });
  } catch (error) {
    console.error("Error getting Pro plans:", error);
    return res.status(error.statusCode || 500).json({
      success: false,
      message: error.message || "Failed to fetch Pro plans",
    });
  }
}

async function getPayOSUrls(req, res) {
  try {
    const result = updateProService.getPayOSUrls();

    return res.status(200).json({
      success: true,
      data: result,
    });
  } catch (error) {
    console.error("Error getting PayOS URLs:", error);
    return res.status(error.statusCode || 500).json({
      success: false,
      message: error.message || "Failed to fetch PayOS URLs",
    });
  }
}

module.exports = {
  createProCheckout,
  handlePayOSWebhook,
  getProStatus,
  getProPlans,
  getPayOSUrls,
};
