const mongoose = require("mongoose");

const ConsultationSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "Users", required: true }, // Bệnh nhân
    nutritionistId: { type: mongoose.Schema.Types.ObjectId, ref: "Nutritionist", required: true }, // Bác sĩ
    diagnosis: { type: String, required: true }, // Chẩn đoán
    recommendations: { type: String, required: true }, // Lời khuyên
    notes: { type: String }, // Ghi chú thêm
  },
  { timestamps: true }
);

module.exports = mongoose.models.Consultation || mongoose.model("Consultation", ConsultationSchema);