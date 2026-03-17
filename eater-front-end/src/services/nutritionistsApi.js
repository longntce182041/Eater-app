import axiosClient from "../api/axiosClient";

export const nutritionistsApi = {
  getNutritionists(params = {}) {
    return axiosClient.get("/nutritionists", { params });
  },

  getNutritionistById(id) {
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
    return axiosClient.get("/users", {
      params: {
        role: "nutritionist",
        limit: 1000,
      },
    });
  },
};
