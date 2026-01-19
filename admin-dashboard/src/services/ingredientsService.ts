import { apiClient } from './apiClient';
import type { Ingredient, IngredientsResponse } from '@types/ingredient';

/**
 * Ingredients management service
 */
export const ingredientsService = {
  /**
   * Get paginated list of ingredients
   */
  async getIngredients(params: { page?: number; search?: string }): Promise<IngredientsResponse> {
    const queryParams = new URLSearchParams();
    if (params.page) queryParams.append('page', params.page.toString());
    if (params.search) queryParams.append('search', params.search);
    return apiClient.get<IngredientsResponse>(`/admin/ingredients?${queryParams.toString()}`);
  },

  /**
   * Get ingredient by ID
   */
  async getIngredientById(id: string): Promise<Ingredient> {
    return apiClient.get<Ingredient>(`/admin/ingredients/${id}`);
  },

  /**
   * Create new ingredient
   */
  async createIngredient(data: Omit<Ingredient, 'id'>): Promise<Ingredient> {
    return apiClient.post<Ingredient>('/admin/ingredients', data);
  },

  /**
   * Update ingredient
   */
  async updateIngredient(id: string, data: Partial<Ingredient>): Promise<Ingredient> {
    return apiClient.patch<Ingredient>(`/admin/ingredients/${id}`, data);
  },

  /**
   * Delete ingredient
   */
  async deleteIngredient(id: string): Promise<void> {
    return apiClient.delete(`/admin/ingredients/${id}`);
  },

  /**
   * Bulk import ingredients
   */
  async bulkImport(file: File): Promise<{ imported: number; errors: string[] }> {
    const formData = new FormData();
    formData.append('file', file);
    return apiClient.post('/admin/ingredients/bulk-import', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
  },
};
