import apiClient from "./apiClient";

const API_BASE_URL = "/nutritionist-schedules";

// ===== Admin Schedule Management =====

export const createNutritionistSchedule = async (data) => {
  const response = await apiClient.post(`${API_BASE_URL}`, data);
  return response.data.data;
};

export const getAllNutritionistSchedules = async () => {
  const response = await apiClient.get(`${API_BASE_URL}/all`);
  return response.data.data || [];
};

export const getMySchedule = async () => {
  const response = await apiClient.get(`${API_BASE_URL}/my-schedule`);
  return response.data.data;
};

export const getNutritionistScheduleById = async (scheduleId) => {
  const response = await apiClient.get(`${API_BASE_URL}/${scheduleId}`);
  return response.data.data;
};

export const getNutritionistScheduleByNutritionistId = async (nutritionistId) => {
  const response = await apiClient.get(`${API_BASE_URL}/nutritionist/${nutritionistId}`);
  return response.data.data;
};

export const updateNutritionistSchedule = async (scheduleId, data) => {
  const response = await apiClient.put(`${API_BASE_URL}/${scheduleId}`, data);
  return response.data.data;
};

export const deleteNutritionistSchedule = async (scheduleId) => {
  const response = await apiClient.delete(`${API_BASE_URL}/${scheduleId}`);
  return response.data.data;
};

// ===== Schedule Change Requests =====

export const requestScheduleChange = async (data) => {
  const response = await apiClient.post(`${API_BASE_URL}/change-requests/request`, data);
  return response.data.data;
};

export const getNutritionistChangeRequests = async (nutritionistId, status) => {
  const params = status ? `?status=${status}` : "";
  const response = await apiClient.get(
    `${API_BASE_URL}/change-requests/nutritionist/${nutritionistId}${params}`
  );
  return response.data.data || [];
};

export const getAllChangeRequests = async (status) => {
  const params = status ? `?status=${status}` : "";
  const response = await apiClient.get(`${API_BASE_URL}/change-requests/all${params}`);
  return response.data.data || [];
};

// ===== Get Nutritionists =====

export const getAllNutritionists = async () => {
  const response = await apiClient.get(`${API_BASE_URL}/nutritionists`);
  return response.data.data || [];
};

export const approveChangeRequest = async (requestId, data) => {
  const response = await apiClient.patch(
    `${API_BASE_URL}/change-requests/${requestId}/approve`,
    data
  );
  return response.data.data;
};

export const rejectChangeRequest = async (requestId, data) => {
  const response = await apiClient.patch(
    `${API_BASE_URL}/change-requests/${requestId}/reject`,
    data
  );
  return response.data.data;
};
