const micronutrientService = require("../services/micronutrient.management.service");
const { validateCreateMicronutrient, validateUpdateMicronutrient } = require("../validators/micronutrient.management.validator");

class MicronutrientManagementController {
    
    async getMicronutrients(req, res) {
        try {
            const result = await micronutrientService.getAllMicronutrients(req.query);
            res.json({ success: true, data: result });
        } catch (error) {
            res.status(500).json({ success: false, message: error.message });
        }
    }

    
    async getMicronutrientDetail(req, res) {
        try {
            const micronutrient = await micronutrientService.getMicronutrientById(req.params.id);
            res.json({ success: true, data: micronutrient });
        } catch (error) {
            res.status(404).json({ success: false, message: error.message });
        }
    }

    
    async createMicronutrient(req, res) {
        try {
            const { errors, isValid } = validateCreateMicronutrient(req.body);
            if (!isValid) return res.status(400).json({ success: false, errors });

            const newMicronutrient = await micronutrientService.createMicronutrient(req.body);
            res.status(201).json({ success: true, message: "Micronutrient created successfully", data: newMicronutrient });
        } catch (error) {
            res.status(400).json({ success: false, message: error.message });
        }
    }

    
    async updateMicronutrient(req, res) {
        try {
            const { errors, isValid } = validateUpdateMicronutrient(req.body);
            if (!isValid) return res.status(400).json({ success: false, errors });

            const updatedMicronutrient = await micronutrientService.updateMicronutrient(req.params.id, req.body);
            res.json({ success: true, message: "Micronutrient updated successfully", data: updatedMicronutrient });
        } catch (error) {
            res.status(400).json({ success: false, message: error.message });
        }
    }

    
    async deleteMicronutrient(req, res) {
        try {
            await micronutrientService.deleteMicronutrient(req.params.id);
            res.json({ success: true, message: "Micronutrient deleted successfully" });
        } catch (error) {
            res.status(400).json({ success: false, message: error.message });
        }
    }
}

module.exports = new MicronutrientManagementController();
