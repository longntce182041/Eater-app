import axiosClient from "../api/axiosClient";

// Lớp API client cho module nutritionist.
// Page/View gọi các hàm này thay vì gọi axios trực tiếp để:
// - gom endpoint cùng module
// - dễ đổi endpoint/headers về sau
// - code page gọn hơn
export const nutritionistsApi = {
  getNutritionists(params = {}) {
    // Admin view nutritionist dashboard/list: lấy danh sách nutritionist có filter.
    return axiosClient.get("/nutritionists", { params });
  },

  getMyProfessionalProfile() {
    // Nutritionist tự xem hồ sơ nghề nghiệp của chính mình.
    return axiosClient.get("/nutritionists/profile/me");
  },

  upsertMyProfessionalProfile(data) {
    // Nutritionist cập nhật hoặc tạo mới hồ sơ nghề nghiệp.
    return axiosClient.put("/nutritionists/profile/me", data);
  },

  getNutritionistById(id) {
    // Admin xem chi tiết một nutritionist.
    return axiosClient.get(`/nutritionists/${id}`);
  },

  createNutritionist(data) {
    return axiosClient.post("/nutritionists/create", data);
  },

  updateNutritionist(id, data) {
    return axiosClient.put(`/nutritionists/update/${id}`, data);
  },

  deleteNutritionist(id) {
    return axiosClient.delete(`/nutritionists/delete/${id}`);
  },

  getNutritionistUsers() {
    // Hỗ trợ UI cần danh sách user có role nutritionist để gán/liên kết.
    return axiosClient.get("/users", {
      params: {
        role: "nutritionist",
        limit: 1000,
      },
    });
  },
};
