import { apiClient } from './apiClient';
import type { Micronutrient } from '@types/micronutrient';

/**
 * Micronutrients management service
 */
export const micronutrientsService = {
  /**
   * Get all micronutrients
   */
  async getMicronutrients(): Promise<Micronutrient[]> {
    return apiClient.get<Micronutrient[]>('/admin/micronutrients');
  },

  /**
   * Get micronutrient by ID
   */
  async getMicronutrientById(id: string): Promise<Micronutrient> {
    return apiClient.get<Micronutrient>(`/admin/micronutrients/${id}`);
  },

  /**
   * Create new micronutrient
   */
  async createMicronutrient(data: Omit<Micronutrient, 'id'>): Promise<Micronutrient> {
    return apiClient.post<Micronutrient>('/admin/micronutrients', data);
  },

  /**
   * Update micronutrient
   */
  async updateMicronutrient(id: string, data: Partial<Micronutrient>): Promise<Micronutrient> {
    return apiClient.patch<Micronutrient>(`/admin/micronutrients/${id}`, data);
  },

  /**
   * Delete micronutrient
   */
  async deleteMicronutrient(id: string): Promise<void> {
    return apiClient.delete(`/admin/micronutrients/${id}`);
  },

  /**
   * Get daily recommended values
   */
  async getDailyRecommendedValues(): Promise<Record<string, number>> {
    return apiClient.get('/admin/micronutrients/daily-values');
  },
};
