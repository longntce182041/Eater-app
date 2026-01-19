import { apiClient } from './apiClient';
import type { User, UserFilters, UsersResponse } from '@types/user';

/**
 * Users management service
 */
export const usersService = {
  /**
   * Get paginated list of users
   */
  async getUsers(params: { page?: number; filters?: UserFilters }): Promise<UsersResponse> {
    const queryParams = new URLSearchParams();
    if (params.page) queryParams.append('page', params.page.toString());
    if (params.filters) {
      Object.entries(params.filters).forEach(([key, value]) => {
        if (value) queryParams.append(key, String(value));
      });
    }
    return apiClient.get<UsersResponse>(`/admin/users?${queryParams.toString()}`);
  },

  /**
   * Get user by ID
   */
  async getUserById(id: string): Promise<User> {
    return apiClient.get<User>(`/admin/users/${id}`);
  },

  /**
   * Update user
   */
  async updateUser(id: string, data: Partial<User>): Promise<User> {
    return apiClient.patch<User>(`/admin/users/${id}`, data);
  },

  /**
   * Delete user
   */
  async deleteUser(id: string): Promise<void> {
    return apiClient.delete(`/admin/users/${id}`);
  },

  /**
   * Ban user
   */
  async banUser(id: string, reason: string): Promise<User> {
    return apiClient.post<User>(`/admin/users/${id}/ban`, { reason });
  },

  /**
   * Unban user
   */
  async unbanUser(id: string): Promise<User> {
    return apiClient.post<User>(`/admin/users/${id}/unban`);
  },

  /**
   * Get user activity log
   */
  async getUserActivity(id: string, page: number = 1): Promise<unknown> {
    return apiClient.get(`/admin/users/${id}/activity?page=${page}`);
  },
};
