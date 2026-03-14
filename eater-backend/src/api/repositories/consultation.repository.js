const { ConsultationRequest } = require("../../models/consultation_request");
const { ConsultationReply } = require("../../models/consultation_reply");

/**
 * Create a new consultation request.
 */
async function createRequest(data) {
  return ConsultationRequest.create(data);
}

/**
 * Find all consultations for a user (paginated).
 */
async function findByUserId(userId, { page = 1, limit = 10, status } = {}) {
  const filter = { userId };
  if (status) filter.status = status;

  const skip = (page - 1) * limit;
  const [items, total] = await Promise.all([
    ConsultationRequest.find(filter)
      .populate("nutritionistId", "fullName specialization")
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit),
    ConsultationRequest.countDocuments(filter),
  ]);
  return { items, total, page, limit };
}

/**
 * Find all consultations assigned to a nutritionist (paginated).
 */
async function findByNutritionistId(
  nutritionistId,
  { page = 1, limit = 10, status } = {}
) {
  const filter = { nutritionistId };
  if (status) filter.status = status;

  const skip = (page - 1) * limit;
  const [items, total] = await Promise.all([
    ConsultationRequest.find(filter)
      .populate("userId", "email")
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit),
    ConsultationRequest.countDocuments(filter),
  ]);
  return { items, total, page, limit };
}

/**
 * Find all consultations (admin view, paginated).
 */
async function findAll({ page = 1, limit = 10, status } = {}) {
  const filter = {};
  if (status) filter.status = status;

  const skip = (page - 1) * limit;
  const [items, total] = await Promise.all([
    ConsultationRequest.find(filter)
      .populate("userId", "email")
      .populate("nutritionistId", "fullName specialization")
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit),
    ConsultationRequest.countDocuments(filter),
  ]);
  return { items, total, page, limit };
}

/**
 * Find a single consultation by ID.
 */
async function findById(id) {
  return ConsultationRequest.findById(id)
    .populate("userId", "email")
    .populate("nutritionistId", "fullName specialization experience");
}

/**
 * Update consultation status.
 */
async function updateStatus(id, status) {
  return ConsultationRequest.findByIdAndUpdate(
    id,
    { status },
    { new: true, runValidators: true }
  );
}

/**
 * Assign a nutritionist to a consultation.
 */
async function assignNutritionist(id, nutritionistId) {
  return ConsultationRequest.findByIdAndUpdate(
    id,
    { nutritionistId, status: "accepted" },
    { new: true }
  );
}

/**
 * Create a reply to a consultation.
 */
async function createReply(data) {
  return ConsultationReply.create(data);
}

/**
 * Find all replies for a consultation.
 */
async function findRepliesByConsultation(consultationId) {
  return ConsultationReply.find({ consultationId })
    .populate("senderId", "email")
    .sort({ createdAt: 1 });
}

module.exports = {
  createRequest,
  findByUserId,
  findByNutritionistId,
  findAll,
  findById,
  updateStatus,
  assignNutritionist,
  createReply,
  findRepliesByConsultation,
};
