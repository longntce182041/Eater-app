const consultationService = require("../services/consultation.service");

const VALID_STATUSES = ["pending", "accepted", "answered", "closed"];
const VALID_CATEGORIES = ["diet", "weight", "health_goal", "meal_plan", "other"];

function formatConsultation(c) {
  return {
    id: c._id,
    title: c.title,
    message: c.message,
    category: c.category,
    status: c.status,
    user: c.userId ? { id: c.userId._id, email: c.userId.email } : null,
    nutritionist: c.nutritionistId
      ? {
        id: c.nutritionistId._id,
        fullName: c.nutritionistId.fullName,
        specialization: c.nutritionistId.specialization,
      }
      : null,
    attachedMealPlanId: c.attachedMealPlanId || null,
    createdAt: c.createdAt,
    updatedAt: c.updatedAt,
  };
}

function formatReply(r) {
  return {
    id: r._id,
    sender: { id: r.senderId?._id, email: r.senderId?.email },
    senderRole: r.senderRole,
    content: r.content,
    createdAt: r.createdAt,
  };
}

/**
 * POST /api/consultations
 * Create a new consultation request (user).
 */
exports.createConsultation = async (req, res) => {
  try {
    const userId = req.user?.id;
    if (!userId) {
      return res
        .status(401)
        .json({ success: false, message: "Authentication required", code: "UNAUTHORIZED" });
    }

    const { title, message, category, nutritionistId, attachedMealPlanId } = req.body;

    if (!title || title.trim().length < 3) {
      return res
        .status(400)
        .json({ success: false, message: "Title must be at least 3 characters", code: "INVALID_TITLE" });
    }
    if (!message || message.trim().length < 10) {
      return res
        .status(400)
        .json({ success: false, message: "Message must be at least 10 characters", code: "INVALID_MESSAGE" });
    }
    if (!category || !VALID_CATEGORIES.includes(category)) {
      return res.status(400).json({
        success: false,
        message: `Category must be one of: ${VALID_CATEGORIES.join(", ")}`,
        code: "INVALID_CATEGORY",
      });
    }

    const consultation = await consultationService.createConsultation(userId, {
      title: title.trim(),
      message: message.trim(),
      category,
      nutritionistId,
      attachedMealPlanId,
    });

    return res.status(201).json({
      success: true,
      data: formatConsultation(consultation),
      message: "Consultation request submitted successfully",
    });
  } catch (error) {
    console.error("Error creating consultation:", error);
    return res.status(error.statusCode || 500).json({
      success: false,
      message: error.message || "Failed to create consultation",
      code: error.code || "CREATE_CONSULTATION_ERROR",
    });
  }
};

/**
 * GET /api/consultations/my
 * Get the authenticated user's consultations.
 */
exports.getMyConsultations = async (req, res) => {
  try {
    const userId = req.user?.id;
    if (!userId) {
      return res
        .status(401)
        .json({ success: false, message: "Authentication required", code: "UNAUTHORIZED" });
    }

    const result = await consultationService.getUserConsultations(userId, req.query);
    return res.json({
      success: true,
      data: {
        items: result.items.map(formatConsultation),
        total: result.total,
        page: result.page,
        limit: result.limit,
      },
    });
  } catch (error) {
    console.error("Error fetching consultations:", error);
    return res.status(500).json({
      success: false,
      message: error.message || "Failed to fetch consultations",
      code: "FETCH_CONSULTATIONS_ERROR",
    });
  }
};

/**
 * GET /api/consultations/requests
 * Get consultations assigned to the requesting nutritionist (or all for admin).
 */
exports.getNutritionistRequests = async (req, res) => {
  try {
    const userId = req.user?.id;
    const role = req.user?.role;

    let result;
    if (role === "admin") {
      result = await consultationService.getAllConsultations(req.query);
    } else {
      // Find the Nutritionist record for this user
      const { Nutritionist } = require("../../models/nutritionist");
      const nutritionist = await Nutritionist.findOne({ userId });
      if (!nutritionist) {
        // No Nutritionist profile yet — show all consultations as fallback
        result = await consultationService.getAllConsultations(req.query);
      } else {
        result = await consultationService.getNutritionistConsultations(
          nutritionist._id,
          req.query
        );
      }
    }

    return res.json({
      success: true,
      data: {
        items: result.items.map(formatConsultation),
        total: result.total,
        page: result.page,
        limit: result.limit,
      },
    });
  } catch (error) {
    console.error("Error fetching nutritionist requests:", error);
    return res.status(500).json({
      success: false,
      message: error.message || "Failed to fetch requests",
      code: "FETCH_REQUESTS_ERROR",
    });
  }
};

/**
 * GET /api/consultations/:id
 * Get a single consultation with its replies.
 */
exports.getConsultationDetail = async (req, res) => {
  try {
    const requesterId = req.user?.id;
    const requesterRole = req.user?.role;
    if (!requesterId) {
      return res
        .status(401)
        .json({ success: false, message: "Authentication required", code: "UNAUTHORIZED" });
    }

    const { id } = req.params;
    const { consultation, replies } = await consultationService.getConsultationDetail(
      id,
      requesterId,
      requesterRole
    );

    return res.json({
      success: true,
      data: {
        ...formatConsultation(consultation),
        replies: replies.map(formatReply),
      },
    });
  } catch (error) {
    console.error("Error fetching consultation detail:", error);
    return res.status(error.statusCode || 500).json({
      success: false,
      message: error.message || "Failed to fetch consultation",
      code: error.code || "FETCH_DETAIL_ERROR",
    });
  }
};

/**
 * POST /api/consultations/:id/reply
 * Add a reply to a consultation (nutritionist or admin).
 */
exports.replyToConsultation = async (req, res) => {
  try {
    const senderId = req.user?.id;
    const senderRole = req.user?.role;
    if (!senderId) {
      return res
        .status(401)
        .json({ success: false, message: "Authentication required", code: "UNAUTHORIZED" });
    }

    const { id } = req.params;
    const { content } = req.body;

    if (!content || content.trim().length < 2) {
      return res
        .status(400)
        .json({ success: false, message: "Reply content is required", code: "INVALID_CONTENT" });
    }

    const reply = await consultationService.replyToConsultation(
      id,
      senderId,
      senderRole,
      content.trim()
    );

    return res.status(201).json({
      success: true,
      data: formatReply(reply),
      message: "Reply sent successfully",
    });
  } catch (error) {
    console.error("Error posting reply:", error);
    return res.status(error.statusCode || 500).json({
      success: false,
      message: error.message || "Failed to post reply",
      code: error.code || "REPLY_ERROR",
    });
  }
};

/**
 * PATCH /api/consultations/:id/status
 * Update consultation status (nutritionist/admin, or owner for closing).
 */
exports.updateConsultationStatus = async (req, res) => {
  try {
    const requesterId = req.user?.id;
    const requesterRole = req.user?.role;
    if (!requesterId) {
      return res
        .status(401)
        .json({ success: false, message: "Authentication required", code: "UNAUTHORIZED" });
    }

    const { id } = req.params;
    const { status } = req.body;

    if (!status || !VALID_STATUSES.includes(status)) {
      return res.status(400).json({
        success: false,
        message: `Status must be one of: ${VALID_STATUSES.join(", ")}`,
        code: "INVALID_STATUS",
      });
    }

    const updated = await consultationService.updateConsultationStatus(
      id,
      status,
      requesterId,
      requesterRole
    );

    return res.json({
      success: true,
      data: formatConsultation(updated),
      message: "Status updated",
    });
  } catch (error) {
    console.error("Error updating status:", error);
    return res.status(error.statusCode || 500).json({
      success: false,
      message: error.message || "Failed to update status",
      code: error.code || "UPDATE_STATUS_ERROR",
    });
  }
};

/**
 * GET /api/consultations/nutritionists
 * Get list of available nutritionists.
 */
exports.getNutritionists = async (req, res) => {
  try {
    const nutritionists = await consultationService.getNutritionists();
    return res.json({
      success: true,
      data: nutritionists.map((n) => ({
        id: n._id,
        fullName: n.fullName,
        specialization: n.specialization,
        experience: n.experience,
        email: n.userId?.email,
      })),
    });
  } catch (error) {
    console.error("Error fetching nutritionists:", error);
    return res.status(500).json({
      success: false,
      message: error.message || "Failed to fetch nutritionists",
      code: "FETCH_NUTRITIONISTS_ERROR",
    });
  }
};
