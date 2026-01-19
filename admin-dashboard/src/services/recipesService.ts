import { apiClient } from './apiClient';
import type { Recipe, RecipeFilters, RecipesResponse } from '@types/recipe';

/**
 * Recipes management service
 */
export const recipesService = {
  /**
   * Get paginated list of recipes
   */
  async getRecipes(params: { page?: number; filters?: RecipeFilters }): Promise<RecipesResponse> {
    const queryParams = new URLSearchParams();
    if (params.page) queryParams.append('page', params.page.toString());
    if (params.filters) {
      Object.entries(params.filters).forEach(([key, value]) => {
        if (value) queryParams.append(key, String(value));
      });
    }
    return apiClient.get<RecipesResponse>(`/admin/recipes?${queryParams.toString()}`);
  },

  /**
   * Get recipe by ID
   */
  async getRecipeById(id: string): Promise<Recipe> {
    return apiClient.get<Recipe>(`/admin/recipes/${id}`);
  },

  /**
   * Create new recipe
   */
  async createRecipe(data: Omit<Recipe, 'id'>): Promise<Recipe> {
    return apiClient.post<Recipe>('/admin/recipes', data);
  },

  /**
   * Update recipe
   */
  async updateRecipe(id: string, data: Partial<Recipe>): Promise<Recipe> {
    return apiClient.patch<Recipe>(`/admin/recipes/${id}`, data);
  },

  /**
   * Delete recipe
   */
  async deleteRecipe(id: string): Promise<void> {
    return apiClient.delete(`/admin/recipes/${id}`);
  },

  /**
   * Approve recipe for publication
   */
  async approveRecipe(id: string): Promise<Recipe> {
    return apiClient.post<Recipe>(`/admin/recipes/${id}/approve`);
  },

  /**
   * Reject recipe
   */
  async rejectRecipe(id: string, reason: string): Promise<Recipe> {
    return apiClient.post<Recipe>(`/admin/recipes/${id}/reject`, { reason });
  },

  /**
   * Feature recipe on homepage
   */
  async featureRecipe(id: string, featured: boolean): Promise<Recipe> {
    return apiClient.patch<Recipe>(`/admin/recipes/${id}`, { featured });
  },
};
