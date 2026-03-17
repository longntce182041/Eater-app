import axiosClient from '../api/axiosClient';

export const chatApi = {
    /** GET /api/chat/contacts — list of users nutritionist can chat with */
    getContacts() {
        return axiosClient.get('/chat/contacts');
    },

    /** GET /api/chat/user/:userId/messages — nutritionist: history with a user */
    getHistory(userId, params = {}) {
        return axiosClient.get(`/chat/user/${userId}/messages`, { params });
    },
};
