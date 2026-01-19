import { apiClient } from './apiClient';
import type { Nutritionist, NutritionistsResponse, VerificationStatus } from '@types/nutritionist';

/**
 * Nutritionists management service
 */
export const nutritionistsService = {
  /**
   * Get paginated list of nutritionists
   */
  async getNutritionists(params: { page?: number; status?: string }): Promise<NutritionistsResponse> {
    const queryParams = new URLSearchParams();
    if (params.page) queryParams.append('page', params.page.toString());
    if (params.status) queryParams.append('status', params.status);
    return apiClient.get<NutritionistsResponse>(`/admin/nutritionists?${queryParams.toString()}`);
  },

  /**
   * Get nutritionist by ID
   */
  async getNutritionistById(id: string): Promise<Nutritionist> {
    return apiClient.get<Nutritionist>(`/admin/nutritionists/${id}`);
  },

  /**
   * Get pending verification requests
   */
  async getPendingVerifications(): Promise<Nutritionist[]> {
    return apiClient.get<Nutritionist[]>('/admin/nutritionists/pending-verifications');
  },

  /**
   * Verify nutritionist credentials
   */
  async verifyCredentials(
    id: string,
    status: VerificationStatus,
    notes?: string
  ): Promise<Nutritionist> {
    return apiClient.post<Nutritionist>(`/admin/nutritionists/${id}/verify`, {
      status,
      notes,
    });
  },

  /**
   * Request additional documents
   */
  async requestDocuments(id: string, documentTypes: string[]): Promise<void> {
    return apiClient.post(`/admin/nutritionists/${id}/request-documents`, {
      documentTypes,
    });
  },

  /**
   * Suspend nutritionist
   */
  async suspendNutritionist(id: string, reason: string): Promise<Nutritionist> {
    return apiClient.post<Nutritionist>(`/admin/nutritionists/${id}/suspend`, { reason });
  },
};
