import apiClient from "./apiClient";

export const usersApi = {
  getUsers() {
    return apiClient.get("/users");
  },
  getUserById(id) {
    return apiClient.get(`/users/${id}`);
  },
  createUser(data) {
    return apiClient.post("/users/create", data);
  },
  updateUser(id, data) {
    return apiClient.put(`/users/update/${id}`, data);
  },
  deactivateUser(id) {
    return apiClient.delete(`/users/delete/${id}`);
  },
};
