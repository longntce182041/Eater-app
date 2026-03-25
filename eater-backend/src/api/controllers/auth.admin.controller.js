const authService = require("../services/auth.admin.service");
const { validateLoginInput } = require("../validators/auth.admin.validators");

class AuthAdminController {
  // [POST] /api/auth/admin/login
  async loginAdmin(req, res) {
    try {
      const { email, password } = req.body;

      // 1. Validate Input
      const { errors, isValid } = validateLoginInput(req.body);
      if (!isValid) {
        return res.status(400).json({ success: false, errors });
      }

      // 2. Gọi Service xử lý
      const result = await authService.loginAdmin(email, password);

      // 3. Trả về kết quả thành công
      return res.status(200).json({
        success: true,
        message: "Admin login successfully",
        data: result,
      });
    } catch (error) {
      // Xử lý lỗi từ Service trả về
      let statusCode = 500;
      if (
        error.message === "User not found" ||
        error.message === "Invalid credentials"
      ) {
        statusCode = 401; // Unauthorized
      } else if (
        error.message.includes("Access denied") ||
        error.message === "Account is inactive"
      ) {
        statusCode = 403; // Forbidden
      }

      return res.status(statusCode).json({
        success: false,
        message: error.message,
      });
    }
  }
}

module.exports = new AuthAdminController();
