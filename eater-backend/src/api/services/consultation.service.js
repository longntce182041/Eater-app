const consultationRepo = require("../repositories/consultation.repository");
const { Nutritionist } = require("../../models/nutritionist");
const User = require("../../models/User");
const {
  sendConsultationRequestEmail,
  sendConsultationReplyEmail,
} = require("../../utils/mailer");

/**
 * Create a new consultation request.
 * Optionally sends an email to the assigned nutritionist.
 */
async function createConsultation(userId, dto) {
  const { title, message, category, nutritionistId, attachedMealPlanId } = dto;

  const consultation = await consultationRepo.createRequest({
    userId,
    nutritionistId: nutritionistId || null,
    title,
    message,
    category,
    attachedMealPlanId: attachedMealPlanId || null,
  });

  // Notify nutritionist via email (best-effort — don't fail the request)
  if (nutritionistId) {
    try {
      const nutritionist = await Nutritionist.findById(nutritionistId).populate(
        "userId",
        "email"
      );
      const user = await User.findById(userId).select("email");
      if (nutritionist?.userId?.email) {
        await sendConsultationRequestEmail({
          to: nutritionist.userId.email,
          userName: user?.email || "A user",
          title,
        });
      }
    } catch (err) {
      console.error("Failed to send consultation request email:", err.message);
    }
  }

  return consultation;
}

/**
 * Get consultations for the authenticated user.
 */
async function getUserConsultations(userId, query) {
  const page = parseInt(query.page) || 1;
  const limit = parseInt(query.limit) || 10;
  const status = query.status || null;
  return consultationRepo.findByUserId(userId, { page, limit, status });
}

/**
 * Get consultations assigned to a nutritionist.
 */
async function getNutritionistConsultations(nutritionistObjectId, query) {
  const page = parseInt(query.page) || 1;
  const limit = parseInt(query.limit) || 10;
  const status = query.status || null;
  return consultationRepo.findByNutritionistId(nutritionistObjectId, {
    page,
    limit,
    status,
  });
}

/**
 * Get all consultations (admin).
 */
async function getAllConsultations(query) {
  const page = parseInt(query.page) || 1;
  const limit = parseInt(query.limit) || 20;
  const status = query.status || null;
  return consultationRepo.findAll({ page, limit, status });
}

/**
 * Get detailed view of a consultation including replies.
 * Checks that requester is allowed to view.
 */
async function getConsultationDetail(consultationId, requesterId, requesterRole) {
  const consultation = await consultationRepo.findById(consultationId);

  if (!consultation) {
    const err = new Error("Consultation not found");
    err.statusCode = 404;
    err.code = "CONSULTATION_NOT_FOUND";
    throw err;
  }

  const isOwner = consultation.userId?._id?.toString() === requesterId;
  const isAdminOrNutritionist =
    requesterRole === "admin" || requesterRole === "nutritionist";

  if (!isOwner && !isAdminOrNutritionist) {
    const err = new Error("You do not have access to this consultation");
    err.statusCode = 403;
    err.code = "FORBIDDEN";
    throw err;
  }

  const replies = await consultationRepo.findRepliesByConsultation(consultationId);
  return { consultation, replies };
}

/**
 * Reply to a consultation (nutritionist or admin).
 * Updates status to 'answered' if it was pending/accepted.
 */
async function replyToConsultation(consultationId, senderId, senderRole, content) {
  const consultation = await consultationRepo.findById(consultationId);

  if (!consultation) {
    const err = new Error("Consultation not found");
    err.statusCode = 404;
    err.code = "CONSULTATION_NOT_FOUND";
    throw err;
  }

  if (consultation.status === "closed") {
    const err = new Error("Cannot reply to a closed consultation");
    err.statusCode = 400;
    err.code = "CONSULTATION_CLOSED";
    throw err;
  }

  const reply = await consultationRepo.createReply({
    consultationId,
    senderId,
    senderRole,
    content,
  });

  // Auto-update status to 'answered' if nutritionist/admin replies
  if (
    senderRole !== "user" &&
    ["pending", "accepted"].includes(consultation.status)
  ) {
    await consultationRepo.updateStatus(consultationId, "answered");
  }

  // Notify user via email (best-effort)
  try {
    const user = await User.findById(consultation.userId).select("email");
    const sender = await User.findById(senderId).select("email");
    if (user?.email) {
      await sendConsultationReplyEmail({
        to: user.email,
        nutritionistName: sender?.email || "A nutritionist",
        title: consultation.title,
      });
    }
  } catch (err) {
    console.error("Failed to send consultation reply email:", err.message);
  }

  return reply;
}

/**
 * Update consultation status.
 */
async function updateConsultationStatus(consultationId, status, requesterId, requesterRole) {
  const consultation = await consultationRepo.findById(consultationId);

  if (!consultation) {
    const err = new Error("Consultation not found");
    err.statusCode = 404;
    err.code = "CONSULTATION_NOT_FOUND";
    throw err;
  }

  const isOwner = consultation.userId?._id?.toString() === requesterId;

  // Only owner can close; admin/nutritionist can set any status
  if (status === "closed" && !isOwner && !["admin", "nutritionist"].includes(requesterRole)) {
    const err = new Error("Only the owner, admin, or nutritionist can close a consultation");
    err.statusCode = 403;
    err.code = "FORBIDDEN";
    throw err;
  }

  return consultationRepo.updateStatus(consultationId, status);
}

/**
 * Get list of verified nutritionists for user to choose from.
 */
async function getNutritionists() {
  const nutritionists = await Nutritionist.find({ verified: true })
    .select("fullName specialization experience userId");
  // Manual lookup to avoid ref mismatch ("User" vs "Users" in Nutritionist schema)
  return Promise.all(
    nutritionists.map(async (n) => {
      const user = await User.findById(n.userId).select("email");
      return { ...n.toObject(), userId: user ? { _id: user._id, email: user.email } : null };
    })
  );
}

module.exports = {
  createConsultation,
  getUserConsultations,
  getNutritionistConsultations,
  getAllConsultations,
  getConsultationDetail,
  replyToConsultation,
  updateConsultationStatus,
  getNutritionists,
};
