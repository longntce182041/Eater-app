import apiClient from "./apiClient";

export const usersApi = {
  getUsers() {
    return apiClient.get("/admin/users");
  },
  getUserById(id) {
    return apiClient.get(`/admin/users/${id}`);
  },
  createUser(data) {
    return apiClient.post("/admin/users", data);
  },
  updateUser(id, data) {
    return apiClient.put(`/admin/users/${id}`, data);
  },
  deactivateUser(id) {
    return apiClient.patch(`/admin/users/${id}/status`, { active: false });
  },
};
