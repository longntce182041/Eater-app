const nutritionistService = require("../services/nutritionist.management.service");
const {
  validateCreateNutritionist,
  validateUpdateNutritionist,
} = require("../validators/nutritionist.management.validators");
const { getActionMessage } = require("../../utils/actionMessage.util");

class NutritionistManagementController {
  async getNutritionists(req, res) {
    try {
      // Endpoint chính để "view dashboard/list nutritionist":
      // nhận filter/sort/pagination từ query và trả danh sách đã chuẩn hóa.
      const result = await nutritionistService.getAllNutritionists(req.query);
      return res.json({ success: true, data: result });
    } catch (error) {
      return res.status(500).json({ success: false, message: error.message });
    }
  }

  async getNutritionistDetail(req, res) {
    try {
      // Lấy chi tiết một nutritionist để hiển thị modal/trang detail ở frontend.
      const result = await nutritionistService.getNutritionistById(
        req.params.id,
      );
      return res.json({ success: true, data: result });
    } catch (error) {
      return res.status(404).json({ success: false, message: error.message });
    }
  }

  async createNutritionist(req, res) {
    try {
      // Validate đầu vào ở controller trước khi đẩy xuống service.
      // Mục tiêu: trả lỗi rõ ràng cho UI, tránh chạy logic DB khi payload sai.
      const { errors, isValid } = validateCreateNutritionist(req.body);
      if (!isValid) {
        return res.status(400).json({ success: false, errors });
      }

      const result = await nutritionistService.createNutritionist(req.body);
      const message = getActionMessage("create", "Nutritionist");
      return res.status(201).json({ success: true, message, data: result });
    } catch (error) {
      return res.status(400).json({ success: false, message: error.message });
    }
  }

  async updateNutritionist(req, res) {
    try {
      // Update profile nutritionist hiện có.
      // Cũng đi qua validator để giữ dữ liệu nhất quán.
      const { errors, isValid } = validateUpdateNutritionist(req.body);
      if (!isValid) {
        return res.status(400).json({ success: false, errors });
      }

      const result = await nutritionistService.updateNutritionist(
        req.params.id,
        req.body,
      );
      const message = getActionMessage("update", "Nutritionist");
      return res.json({ success: true, message, data: result });
    } catch (error) {
      return res.status(400).json({ success: false, message: error.message });
    }
  }

  async deleteNutritionist(req, res) {
    try {
      // Xóa profile nutritionist theo id (phục vụ thao tác quản trị).
      await nutritionistService.deleteNutritionist(req.params.id);
      const message = getActionMessage("delete", "Nutritionist");
      return res.json({ success: true, message });
    } catch (error) {
      return res.status(400).json({ success: false, message: error.message });
    }
  }
}

module.exports = new NutritionistManagementController();
