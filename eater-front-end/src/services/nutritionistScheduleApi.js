import apiClient from "./apiClient";

const API_BASE_URL = "/nutritionist-schedules";

// ===== Admin Schedule Management =====

export const createNutritionistSchedule = async (data) => {
  const payload = {
    ...data,
    // Backward compatibility: old backend expects single nutritionistId
    nutritionistId:
      data?.nutritionistId ||
      (Array.isArray(data?.nutritionistIds) && data.nutritionistIds.length > 0
        ? data.nutritionistIds[0]
        : undefined),
  };

  try {
    const response = await apiClient.post(`${API_BASE_URL}`, payload);
    return response.data;
  } catch (error) {
    const message = error?.response?.data?.message || "";
    const isLegacyValidation = message.includes(
      "nutritionistId and workDays array are required"
    );
    const ids = Array.isArray(data?.nutritionistIds) ? data.nutritionistIds : [];

    // Fallback for older backend: create one by one
    if (isLegacyValidation && ids.length > 0) {
      const created = [];
      const skipped = [];

      for (const id of ids) {
        try {
          const res = await apiClient.post(`${API_BASE_URL}`, {
            nutritionistId: id,
            workDays: data.workDays,
            specialDays: data.specialDays || [],
          });
          created.push(res.data?.data || res.data);
        } catch (singleErr) {
          skipped.push({
            nutritionistId: id,
            reason: singleErr?.response?.data?.message || "Failed to create schedule",
          });
        }
      }

      if (created.length === 0) {
        throw error;
      }

      return {
        success: true,
        message: `Created ${created.length} schedule(s)`,
        data: created,
        createdCount: created.length,
        skippedCount: skipped.length,
        skipped,
      };
    }

    throw error;
  }
};

export const getAllNutritionistSchedules = async () => {
  // Admin Manage Schedule: lấy toàn bộ schedule để hiển thị danh sách + thao tác.
  const response = await apiClient.get(`${API_BASE_URL}/all`);
  return response.data.data || [];
};

export const getMySchedule = async () => {
  const response = await apiClient.get(`${API_BASE_URL}/my-schedule`);
  return response.data.data;
};

export const getNutritionistScheduleById = async (scheduleId) => {
  // Admin View Schedule Detail theo ID (khi cần truy vấn chi tiết riêng).
  const response = await apiClient.get(`${API_BASE_URL}/${scheduleId}`);
  return response.data.data;
};

export const getNutritionistScheduleByNutritionistId = async (nutritionistId) => {
  const response = await apiClient.get(`${API_BASE_URL}/nutritionist/${nutritionistId}`);
  return response.data.data;
};

export const updateNutritionistSchedule = async (scheduleId, data) => {
  // Admin Update Schedule.
  const response = await apiClient.put(`${API_BASE_URL}/${scheduleId}`, data);
  return response.data.data;
};

export const deleteNutritionistSchedule = async (scheduleId) => {
  // Admin Delete Schedule.
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

export const getAllNutritionists = async ({ availableOnly = false } = {}) => {
  const response = await apiClient.get(`${API_BASE_URL}/nutritionists`, {
    params: { availableOnly },
  });
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
