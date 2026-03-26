import apiClient from "./apiClient";

const BASE_URL = "/nutritionists";

export const getMyProfessionalProfile = async () => {
	const response = await apiClient.get(`${BASE_URL}/profile/me`);
	return response.data;
};

export const upsertMyProfessionalProfile = async (payload) => {
	const response = await apiClient.put(`${BASE_URL}/profile/me`, payload);
	return response.data;
};

