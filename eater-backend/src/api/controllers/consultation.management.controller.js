const consultationService = require("../services/consultation.management.service");
const { validateDiagnosis, validateDietPlan } = require("../validators/consultation.management.validators");

class ConsultationManagementController {

    // Task: Diagnose Nutrition Condition + Send Recommendations
    // [POST] Chẩn đoán & Gợi ý
    async createConsultation(req, res) {
        try {
            const { errors, isValid } = validateDiagnosis(req.body);
            if (!isValid) return res.status(400).json({ success: false, errors });

            const io = req.app.io;
            const result = await consultationService.createDiagnosisAndRecommendation(req.user.id, req.body, io);
            res.status(201).json({ 
                success: true, 
                message: "Diagnosis and recommendations saved successfully! Notification sent to patient.", 
                data: result 
            });
        } catch (error) {
            res.status(400).json({ success: false, message: error.message });
        }
    }

    // [POST] Tạo & Gán Thực Đơn
    async createMealPlan(req, res) {
        try {
            const { errors, isValid } = validateDietPlan(req.body);
            if (!isValid) return res.status(400).json({ success: false, errors });

            const io = req.app.io;
            const result = await consultationService.createAndAssignMealPlan(req.user.id, req.body, io);
            res.status(201).json({ 
                success: true, 
                message: "Personalized meal plan assigned successfully! Notification sent to patient.", 
                data: result 
            });
        } catch (error) {
            res.status(400).json({ success: false, message: error.message });
        }
    }

    // [GET] Xuất Báo Cáo
    async getNutritionReport(req, res) {
        try {
            const patientId = req.params.patientId;
            if (!patientId) return res.status(400).json({ success: false, message: "Patient ID is required" });

            const io = req.app.io;
            const options = {
                sendEmail: String(req.query.sendEmail).toLowerCase() === "true",
                sendChat: String(req.query.sendChat).toLowerCase() === "true",
            };

            const reportData = await consultationService.generateNutritionReport(req.user.id, patientId, io, options);
            res.status(200).json({ 
                success: true, 
                message: "Report generated successfully!",
                data: reportData 
            });
        } catch (error) {
            res.status(400).json({ success: false, message: error.message });
        }
    }

    // Task: View User Health Data
    // [GET] Nutritionist xem dữ liệu sức khỏe user
    async getUserHealthData(req, res) {
        try {
            const patientId = req.params.patientId;
            if (!patientId) {
                return res.status(400).json({ success: false, message: "Patient ID is required" });
            }

            const healthData = await consultationService.getUserHealthData(req.user.id, patientId);
            return res.status(200).json({
                success: true,
                message: "User health data retrieved successfully",
                data: healthData,
            });
        } catch (error) {
            return res.status(400).json({ success: false, message: error.message });
        }
    }
}

module.exports = new ConsultationManagementController();