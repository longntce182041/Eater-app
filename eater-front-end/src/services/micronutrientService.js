import axiosClient from '../api/axiosClient';

const MICRONUTRIENT_API = '/micronutrients';

const micronutrientService = {
    // Get list micronutrients with search & pagination
    getAll: async (params = {}) => {
        try {
            const response = await axiosClient.get(MICRONUTRIENT_API, { params });
            return response.data;
        } catch (error) {
            throw error.response?.data || error;
        }
    },

    // Get micronutrient by ID
    getById: async (id) => {
        try {
            const response = await axiosClient.get(`${MICRONUTRIENT_API}/${id}`);
            return response.data;
        } catch (error) {
            throw error.response?.data || error;
        }
    },

    // Create new micronutrient
    create: async (data) => {
        try {
            const response = await axiosClient.post(`${MICRONUTRIENT_API}/create`, data);
            return response.data;
        } catch (error) {
            throw error.response?.data || error;
        }
    },

    // Update micronutrient
    update: async (id, data) => {
        try {
            const response = await axiosClient.put(`${MICRONUTRIENT_API}/update/${id}`, data);
            return response.data;
        } catch (error) {
            throw error.response?.data || error;
        }
    },

    // Delete micronutrient
    delete: async (id) => {
        try {
            const response = await axiosClient.delete(`${MICRONUTRIENT_API}/delete/${id}`);
            return response.data;
        } catch (error) {
            throw error.response?.data || error;
        }
    },
};

export default micronutrientService;
