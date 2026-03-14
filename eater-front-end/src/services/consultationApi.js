import axiosClient from '../api/axiosClient';

export const consultationApi = {
    getRequests(params = {}) {
        return axiosClient.get('/consultations/requests', { params });
    },
    getDetail(id) {
        return axiosClient.get(`/consultations/${id}`);
    },
    reply(id, content) {
        return axiosClient.post(`/consultations/${id}/reply`, { content });
    },
    updateStatus(id, status) {
        return axiosClient.patch(`/consultations/${id}/status`, { status });
    },
};
